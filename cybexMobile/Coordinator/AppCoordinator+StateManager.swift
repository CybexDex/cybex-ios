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

extension AppCoordinator {
    func fetchTickerData(_ params: AssetPairQueryParams, sub: Bool, priority: Operation.QueuePriority) {
        creator.fetchCurrencyList(params) { [weak self](asset) in
            guard let self = self else { return }
            self.store.dispatch(TickerFetched(asset: asset))
        }
    }

    func fetchKline(_ params: AssetPairQueryParams, gap: Candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
        store.dispatch(creator.fetchMarket(with: false, params: params, priority: .high, callback: { [weak self] (assets) in
            guard let self = self else { return }

            self.store.dispatch(KLineFetched(pair: Pair(base: params.firstAssetId, quote: params.secondAssetId), stick: gap, assets: assets))
            if let vc = vc, let sel = selector {
                self.store.dispatch(RefreshState(sel: sel, vc: vc))
            }
        }))
    }

    func fetchAsset(_ callback:@escaping (() -> Void)) {
        async {
            guard let data = try? await(SimpleHTTPService.fetchIdsInfo()) else {
                main {
                    callback()
                }
                return
            }

            main {
                AssetConfiguration.shared.uniqueIds = data
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
            guard let value = try? await(SimpleHTTPService.requestETHPrice()) else {
                return
            }
            if value.count == 0 {
                return
            }
            main { [weak self] in
                self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
            }
        }

        self.timer = Repeater.every(.seconds(3)) {[weak self] _ in
            guard let value = try? await(SimpleHTTPService.requestETHPrice()) else {
                return
            }
            if value.count == 0 {
                return
            }
            main { [weak self] in
                self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
            }

            guard let marketList = try? await(SimpleHTTPService.fetchMarketListJson()) else {
                return
            }
            main { [weak self] in
                self?.store.dispatch(FecthMarketListAction(data: marketList))
            }
        }

        timer?.start()
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
                AppConfiguration.shared.appCoordinator.fetchTickerData(
                    AssetPairQueryParams(firstAssetId: pair.base,
                                         secondAssetId: pair.quote,
                                         timeGap: 60 * 60,
                                         startTime: start,
                                         endTime: now),
                    sub: sub,
                    priority: priority)
            }
        } else {
            fetch24Markets(UserManager.shared.refreshTime, startTime: start, now: now, sub: sub, priority: priority)
        }
    }

    func fetch24Markets(_ time: TimeInterval, startTime: Date, now: Date, sub: Bool = true, priority: Operation.QueuePriority = .normal) {

        let timeSpace = time / Double(AssetConfiguration.marketBaseAssets.count)

        var refreshTime: TimeInterval = 0
        for index in 0..<AssetConfiguration.marketBaseAssets.count {
            let base = AssetConfiguration.marketBaseAssets[index]
            refreshTime = Double(index) * timeSpace
            let pairs = AssetConfiguration.shared.assetIds.filter({return $0.base == base})
            SwifterSwift.delay(milliseconds: refreshTime * 1000.0) {
                for pair in pairs {
                    if CybexWebSocketService.shared.overload() {
                        return
                    }
                    AppConfiguration.shared.appCoordinator.fetchTickerData(
                        AssetPairQueryParams(firstAssetId: pair.base,
                                             secondAssetId: pair.quote,
                                             timeGap: 60 * 60,
                                             startTime: startTime,
                                             endTime: now),
                        sub: sub,
                        priority: priority)
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
                guard let self = self else {return}
                if reachability.connection == .none ||
                    !CybexWebSocketService.shared.checkNetworConnected() {
                        appCoodinator.fetchPariTimer = nil
                        timer.pause()
                        return
                }
                self.state.property.otherRequestRelyData.accept(1)
                self.request24hMarkets(AssetConfiguration.shared.assetIds, sub: false, priority: priority, isNoFirst: false)
            }
        })
    }

    func requestKlineDetailData(pair: Pair, gap: Candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
        let now = Date()
        let start = now.addingTimeInterval(-gap.rawValue * 199)

        AppConfiguration.shared.appCoordinator.fetchKline(
            AssetPairQueryParams(firstAssetId: pair.base,
                                 secondAssetId: pair.quote,
                                 timeGap: gap.rawValue.int,
                                 startTime: start,
                                 endTime: now),
            gap: gap,
            vc: vc,
            selector: selector)
    }

    func getLatestData() {
        if AssetConfiguration.shared.assetIds.isEmpty {
            fetchAsset {
                var pairs: [Pair] = []
                var count = 0
                for base in AssetConfiguration.marketBaseAssets {
                   
                    SimpleHTTPService.requestMarketList(base: base).done({ (pair) in
                        let piecePair = pair.filter({ (pair) -> Bool in
                            return AssetConfiguration.shared.uniqueIds.contains([pair.base, pair.quote])
                        })
                        if base == AssetConfiguration.ETH {
                            print("base ETH")
                        }
                        count += 1
                        pairs += piecePair
                        if count == AssetConfiguration.marketBaseAssets.count {
                            AssetConfiguration.shared.assetIds = pairs
                            self.request24hMarkets(AssetConfiguration.shared.assetIds, priority: .high)
                        }
                    }).cauterize()
                }
                if appCoodinator.fetchPariTimer == nil || !(appCoodinator.fetchPariTimer!.state.isRunning) {
                    AppConfiguration.shared.appCoordinator.repeatFetchPairInfo(.veryLow)
                }
            }
        } else {
            if appData.assetInfo.count != AssetConfiguration.shared.uniqueIds.count {
                fetchAsset {
                    self.request24hMarkets(AssetConfiguration.shared.assetIds, priority: .high)
                }
            }
            request24hMarkets(AssetConfiguration.shared.assetIds, priority: .high)
            if appCoodinator.fetchPariTimer == nil || !(appCoodinator.fetchPariTimer!.state.isRunning) {
                AppConfiguration.shared.appCoordinator.repeatFetchPairInfo(.veryLow)
            }
        }
    }
}
