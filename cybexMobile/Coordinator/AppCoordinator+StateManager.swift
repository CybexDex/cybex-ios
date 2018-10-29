//
//  AppCoordinator+StateManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import AwaitKit
import Repeat
import SwifterSwift
import Reachability

extension AppCoordinator: AppStateManagerProtocol {

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AppState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

    func fetchData(_ params: AssetPairQueryParams, sub: Bool = true, priority: Foundation.Operation.QueuePriority = .normal) {
        store.dispatch(creator.fetchMarket(with: sub, params: params, priority: priority, callback: { [weak self] (assets) in
            guard let `self` = self else { return }

            self.store.dispatch(MarketsFetched(pair: params, assets: assets))
        }))
    }

    func fetchTickerData(_ params: AssetPairQueryParams, sub: Bool, priority: Operation.QueuePriority) {
        creator.fetchCurrencyList(params) { [weak self](asset) in
            guard let `self` = self else { return }
            self.store.dispatch(TickerFetched(asset: asset))
        }
    }

    func fetchKline(_ params: AssetPairQueryParams, gap: candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
        store.dispatch(creator.fetchMarket(with: false, params: params, priority: .high, callback: { [weak self] (assets) in
            guard let `self` = self else { return }

            self.store.dispatch(KLineFetched(pair: Pair(base: params.firstAssetId, quote: params.secondAssetId), stick: gap, assets: assets))
            if let vc = vc, let sel = selector {
                self.store.dispatch(RefreshState(sel: sel, vc: vc))
            }
        }))
    }

    func fetchAsset(_ callback:@escaping (() -> Void)) {
        async {
            let data = try! await(SimpleHTTPService.fetchIdsInfo())
            main {
                AssetConfiguration.shared.unique_ids = data
                let request = GetObjectsRequest(ids: data) { response in
                    if let assetinfo = response as? [AssetInfo] {
                        for info in assetinfo {
                            self.store.dispatch(AssetInfoAction(assetID: info.id, info: info))
                        }
                        callback()
                    }
                }
                CybexWebSocketService.shared.send(request: request, priority: .veryHigh)
            }
        }
    }

    func fetchEthToRmbPrice() {
        async {
            let value = try! await(SimpleHTTPService.requestETHPrice())
            if value.count == 0 {
                return
            }
            main { [weak self] in
                self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
            }
        }

        self.timer = Repeater.every(.seconds(3)) {[weak self] _ in
            let value = try! await(SimpleHTTPService.requestETHPrice())
            if value.count == 0 {
                return
            }
            main { [weak self] in
                self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
            }

            let marketList = try! await(SimpleHTTPService.fetchMarketListJson())
            main { [weak self] in
                self?.store.dispatch(FecthMarketListAction(data: marketList))
            }
        }

        timer?.start()
    }

    func fetchGetToCyb(_ callback:@escaping(Decimal)->Void) {
        let request = GetTickerRequest(baseName: AssetConfiguration.ETH, quoteName: AssetConfiguration.CYB, response: { [weak self](data) in
            guard let `self` = self else { return }
            if let data = data as? Ticker, let dataDouble = data.latest.toDecimal(), dataDouble != 0 {
                self.getToCybRelation = Decimal(floatLiteral: 1) / dataDouble
                callback(1 / dataDouble)
            } else {
                callback(0)
            }
        })
        CybexWebSocketService.shared.send(request: request)
    }
}

extension AppCoordinator {

    /*
     1 根据base分组
     2 根据refreshTime刷新
     3 延迟函数
     */

    func request24hMarkets(_ pairs: [Pair], sub: Bool = true, totalTime: Double = 3, splits: Int = 3, priority: Operation.QueuePriority = .normal, isNoFirst: Bool = true) {
        let now = Date()
        let curTime = now.timeIntervalSince1970

        var start = now.addingTimeInterval(-3600 * 24)

        let timePassed = (-start.minute * 60 - start.second).double
        start = start.addingTimeInterval(timePassed)
        let filterPairs = pairs.filter { (pair) -> Bool in
            if let refreshTimes = appData.pairsRefreshTimes, let oldTime = refreshTimes[pair] {
                return curTime - oldTime >= 5
            }
            return true
        }

        if isNoFirst {
            for pair in filterPairs {

                AppConfiguration.shared.appCoordinator.fetchTickerData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub, priority: priority)

//                AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub, priority:priority)
            }
        } else {
            fetch24Markets(UserManager.shared.refreshTime, startTime: start, now: now, sub: sub, priority: priority)
        }
    }

    func fetch24Markets(_ time: TimeInterval, startTime: Date, now: Date, sub: Bool = true, priority: Operation.QueuePriority = .normal) {

        let timeSpace = time / Double(AssetConfiguration.market_base_assets.count)

        var refreshTime: TimeInterval = 0
        for index in 0..<AssetConfiguration.market_base_assets.count {
            let base = AssetConfiguration.market_base_assets[index]
            refreshTime = Double(index) * timeSpace
            let pairs = AssetConfiguration.shared.asset_ids.filter({return $0.base == base})
            SwifterSwift.delay(milliseconds: refreshTime * 1000.0) {
                for pair in pairs {
                    if CybexWebSocketService.shared.overload() {
                        return
                    }
                    AppConfiguration.shared.appCoordinator.fetchTickerData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: startTime, endTime: now), sub: sub, priority: priority)

//                    AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: startTime, endTime: now), sub: sub, priority:priority)
                }
            }
        }
    }

    func repeatFetchPairInfo(_ priority: Operation.QueuePriority = .normal) {
        if self.fetchPariTimer != nil {
            self.fetchPariTimer?.pause()
            self.fetchPariTimer = nil
        }

        self.fetchPariTimer = Repeater.every(.seconds(UserManager.shared.refreshTime), { [weak self](timer) in
            main {
                guard let `self` = self else {return}
                if reachability.connection == .none ||
                    !CybexWebSocketService.shared.checkNetworConnected() {
                        appCoodinator.fetchPariTimer = nil
                        timer.pause()
                        return
                }
                self.state.property.otherRequestRelyData.accept(1)
                self.request24hMarkets(AssetConfiguration.shared.asset_ids, sub: false, priority: priority, isNoFirst: false)
            }
        })
    }

    func requestKlineDetailData(pair: Pair, gap: candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
        let now = Date()
        let start = now.addingTimeInterval(-gap.rawValue * 199)

        AppConfiguration.shared.appCoordinator.fetchKline(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: gap.rawValue.int, startTime: start, endTime: now), gap: gap, vc: vc, selector: selector)
    }

    func getLatestData() {
        if AssetConfiguration.shared.asset_ids.isEmpty {
            fetchAsset {
                var pairs: [Pair] = []
                var count = 0
                for base in AssetConfiguration.market_base_assets {
                    SimpleHTTPService.requestMarketList(base: base).done({ (pair) in

                        let piece_pair = pair.filter({ (p) -> Bool in
                            return AssetConfiguration.shared.unique_ids.contains([p.base, p.quote])
                        })
                        count += 1

                        pairs += piece_pair
                        if count == AssetConfiguration.market_base_assets.count {
                            AssetConfiguration.shared.asset_ids = pairs
                            self.request24hMarkets(AssetConfiguration.shared.asset_ids, priority: .high)
                        }
                    }).cauterize()
                }

                if appCoodinator.fetchPariTimer == nil || !(appCoodinator.fetchPariTimer!.state.isRunning) {
                    AppConfiguration.shared.appCoordinator.repeatFetchPairInfo(.veryLow)
                }

            }

        } else {
            if appData.assetInfo.count != AssetConfiguration.shared.unique_ids.count {
                fetchAsset {
                    self.request24hMarkets(AssetConfiguration.shared.asset_ids, priority: .high)
                }
            }
            request24hMarkets(AssetConfiguration.shared.asset_ids, priority: .high)
            if appCoodinator.fetchPariTimer == nil || !(appCoodinator.fetchPariTimer!.state.isRunning) {
                AppConfiguration.shared.appCoordinator.repeatFetchPairInfo(.veryLow)
            }
        }
    }
}
