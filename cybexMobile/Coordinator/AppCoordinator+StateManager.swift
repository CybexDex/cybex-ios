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
import SwiftyJSON
import HandyJSON

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
        AppService.request(target: AppAPI.assetWhiteList, success: { (json) in
            let data = JSON(json).arrayValue.compactMap({String(describing: $0.stringValue)})
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
        }, error: { (_) in
            main {
                callback()
            }
        }) { (_) in
            main {
                callback()
            }
        }

    }

    func fetchEthToRmbPrice() {
        self.requestOuterPrice({[weak self] (value) in
            guard let self = self else { return }

            if value.count == 0 {
                return
            }

            self.store.dispatch(FecthEthToRmbPriceAction(price: value))

        })

        self.timer = Repeater.every(.seconds(3)) {[weak self] _ in
            guard let self = self else { return }
            self.requestOuterPrice({[weak self] (value) in
                guard let self = self else { return }

                if value.count == 0 {
                    return
                }

                self.store.dispatch(FecthEthToRmbPriceAction(price: value))

                AppService.request(target: AppAPI.stickTopMarketPair, success: { (json) in
                    let marketLists = JSON(json).arrayValue.compactMap({ (item) in
                        ImportantMarketPair(base: item["base"].stringValue, quotes: (item["quotes"].arrayObject as? [String])!)
                    })

                    self.store.dispatch(FecthMarketListAction(data: marketLists))
                }, error: { (_) in

                }, failure: { (_) in

                })

            })
        }

        timer?.start()
    }

    func requestOuterPrice(_ callback: @escaping ([RMBPrices]) -> Void) {
        AppService.request(target: AppAPI.outerPrice, success: { (json) in
            let prices = json["prices"].arrayValue.compactMap( { RMBPrices.deserialize(from: $0.dictionaryObject) } )
            callback(prices)
        }, error: { (_) in
            callback([])
        }) { (_) in
            callback([])
        }
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
                    AppService.request(target: AppAPI.marketlist(base: base), success: { (json) in
                        let result = json.arrayValue.compactMap({ Pair(base: base, quote: $0.stringValue) })

                        let piecePair = result.filter({ (pair) -> Bool in
                            return AssetConfiguration.shared.uniqueIds.contains([pair.base, pair.quote])
                        })

                        count += 1
                        pairs += piecePair
                        if count == AssetConfiguration.marketBaseAssets.count {
                            AssetConfiguration.shared.assetIds = pairs
                            self.request24hMarkets(AssetConfiguration.shared.assetIds, priority: .high)
                        }
                    }, error: { (_) in

                    }, failure: { (_) in

                    })

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
