//
//  AppCoordinator+StateManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Repeat
import SwifterSwift
import Reachability
import SwiftyJSON
import HandyJSON
import RxSwift

extension AppCoordinator {
    func fetchTickerData(_ pair: Pair, priority: Operation.QueuePriority) {
        let request = GetTickerRequest(baseName: pair.base, quoteName: pair.quote) { response in
            if let data = response as? Ticker {
                self.store.dispatch(TickerFetched(asset: data))

            }
        }
        CybexWebSocketService.shared.send(request: request, priority: priority)
    }

}

extension AppCoordinator {
    func fetchAllPairsMarkets(_ priority: Operation.QueuePriority = .normal) {
        self.fetchMarketFrom(MarketConfiguration.shared.marketPairs.value, priority: priority)


        if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable {
            self.fetchMarketFrom(MarketConfiguration.shared.gameMarketPairs, priority: priority)
        }

    }

    func fetchMarketFrom(_ pairs: [Pair], priority: Operation.QueuePriority = .normal) {
        if pairs.count > 0 {
           fetchBatchMarketFrom(pairs, priority: priority)
        }

//        for pair in pairs {
//            if CybexWebSocketService.shared.overload() {
//                return
//            }
//            fetchTickerData(pair, priority: priority)
//        }
    }

    func fetchBatchMarketFrom(_ pairs: [Pair], priority: Operation.QueuePriority = .normal) {
       
       let request = GetTickerBatchRequest(pairs: pairs) { response in
          if let data = response as? [Ticker] {
                self.store.dispatch(TickerBatchFetched(assets: data))
          }
       }
       CybexWebSocketService.shared.send(request: request, priority: priority)
    }

    func repeatFetchMarket(_ priority: Operation.QueuePriority = .normal) {
        fetchMarketListTimer?.dispose()

        fetchMarketListTimer = Observable<Int>.interval(UserManager.shared.refreshTime, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (n) in
            guard let self = self else { return }

            if reachability.connection == .unavailable ||
                !CybexWebSocketService.shared.checkNetworConnected() {
                self.fetchMarketListTimer?.dispose()
                return
            }
            self.state.property.otherRequestRelyData.accept(1)
            self.fetchAllPairsMarkets(.veryLow)
        })
    }

    func getAssetInfos(_ ids: [String], completion: (() -> Void)? = nil) {
        let request = GetObjectsRequest(ids: ids, refLib: false) { response in
            if let assetinfo = response as? [AssetInfo] {
                self.store.dispatch(AssetInfoAction(info: assetinfo))
                completion?()
            }
        }
        CybexWebSocketService.shared.send(request: request, priority: .veryHigh)
    }

    func getLatestData() {
        if !AssetConfiguration.shared.whiteListOfIds.value.isEmpty {
            getAssetInfos(AssetConfiguration.shared.whiteListOfIds.value, completion:{ [weak self] in
                if !MarketConfiguration.shared.marketPairs.value.isEmpty {
                    self?.fetchAllPairsMarkets(.high)
                }

                self?.repeatFetchMarket(.veryLow)

            })
        }


    }
}
