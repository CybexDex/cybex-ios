//
//  MarketCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwifterSwift

protocol MarketCoordinatorProtocol {
    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair)
    func setDropBoxViewController()
}

protocol MarketStateManagerProtocol {
    var state: MarketState { get }

    func isExistProjectIntroduction(_ pair: Pair) -> Bool
    func requestKlineDetailData(pair: Pair, gap: Candlesticks)
    func fetchLastMessageId(_ channel: String, callback:@escaping (Int)->())
}

class MarketCoordinator: NavCoordinator {

    var store = Store<MarketState>(
        reducer: marketReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
    
    var state: MarketState {
        return store.state
    }
}

extension MarketCoordinator: MarketCoordinatorProtocol {


    func isExistProjectIntroduction(_ pair: Pair) -> Bool {
        if let projectName = AssetConfiguration.shared.quoteToProjectNames.value[pair.quote.symbol], !projectName.isEmpty {
            return true
        }

        return false
    }

    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair) {
        self.rootVC.tabBarController?.selectedIndex = 2
        self.rootVC.popToRootViewController(animated: false)

        delay(milliseconds: 100) {
            if let baseNavi = self.rootVC.tabBarController?.viewControllers![2] as? BaseNavigationController, let vc = baseNavi.topViewController as? TradeViewController {
                vc.pair = pair
                vc.selectedIndex = isBuy ? 0 : 1
                vc.titlesView?.selectedIndex = vc.selectedIndex
            }
        }

    }

    func setDropBoxViewController() {
        guard let vc = R.storyboard.comprehensive.recordChooseViewController(),
            let marketVC = self.rootVC.topViewController as? MarketViewController,
            let selectedView = marketVC.selectedDropKindView else { return }

        vc.typeIndex = selectedView.dropKind == .time ? .time : .kind
        vc.selectedIndex = selectedView.dropKind == .time ? marketVC.daySelectedIndex : marketVC.indicatorSelectedIndex
        vc.delegate = marketVC
        vc.coordinator = RecordChooseCoordinator(rootVC: self.rootVC)

        marketVC.presentPopOverViewController(vc,
                                              size: CGSize(width: selectedView.width,
                                                           height: selectedView.dropKind == .time ? 102 : 136),
                                              sourceView: selectedView,
                                              offset: CGPoint.zero,
                                              direction: .up)
    }
}

extension MarketCoordinator: MarketStateManagerProtocol {
    func requestKlineDetailData(pair: Pair, gap: Candlesticks) {
        let now = Date()
        let start = now.addingTimeInterval(TimeInterval(-gap.rawValue * 199))

        let queryItem = AssetPairQueryParams(firstAssetId: pair.base,
                                            secondAssetId: pair.quote,
                                            timeGap: gap.rawValue,
                                            startTime: start,
                                            endTime: now)

        let request = GetMarketHistoryRequest(queryParams: queryItem) { response in
            if let buckets = response as? [Bucket] {
                self.handlerKlines(queryItem, data: buckets)
            }
        }

        CybexWebSocketService.shared.send(request: request, priority: .normal)
    }

    func handlerKlines(_ queryItem: AssetPairQueryParams, data: [Bucket]) {
        var data = data
        guard data.count > 0 else {
            self.store.dispatch(KLineFetched(pair: Pair(base: queryItem.firstAssetId, quote: queryItem.secondAssetId), stick: Candlesticks(rawValue: queryItem.timeGap)!, assets: []))
            return
        }

        let firstTrade = data[0]

        guard firstTrade.open > queryItem.startTime.timeIntervalSince1970 else {
            self.store.dispatch(KLineFetched(pair: Pair(base: queryItem.firstAssetId, quote: queryItem.secondAssetId), stick: Candlesticks(rawValue: queryItem.timeGap)!, assets:data))
            return
        }

        var params = queryItem
        params.startTime = queryItem.startTime.addingTimeInterval(TimeInterval(-queryItem.timeGap * 199))
        params.endTime = queryItem.startTime

        let request = GetMarketHistoryRequest(queryParams: params) { response in
            if let buckets = response as? [Bucket], let bucket = buckets.last {
                let close = bucket.openBase
                let quoteClose = bucket.openQuote
                if let addAsset = bucket.copy() as? Bucket {
                    addAsset.closeBase = close
                    addAsset.closeQuote = quoteClose
                    addAsset.openBase = close
                    addAsset.openQuote = quoteClose
                    addAsset.highBase = close
                    addAsset.highQuote = quoteClose
                    addAsset.lowBase = close
                    addAsset.lowQuote = quoteClose
                    addAsset.baseVolume = "0"
                    addAsset.quoteVolume = "0"
                    addAsset.open = params.startTime.timeIntervalSince1970
                    data.prepend(addAsset)
                }
            }

            self.store.dispatch(KLineFetched(pair: Pair(base: params.firstAssetId, quote: params.secondAssetId), stick: Candlesticks(rawValue: params.timeGap)!, assets:data))

        }
        CybexWebSocketService.shared.send(request: request, priority: .normal)
    }

    func fetchLastMessageId(_ channel: String, callback:@escaping (Int)->()) {
        IMService.request(target: IMAPI.messageCount(channel), success: { (json) in
            callback(json.intValue)
        }, error: { (_) in

        }) { (_) in

        }
    }
}
