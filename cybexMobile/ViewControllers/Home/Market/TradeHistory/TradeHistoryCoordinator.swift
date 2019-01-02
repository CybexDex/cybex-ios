//
//  TradeHistoryCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyJSON

protocol TradeHistoryCoordinatorProtocol {
}

protocol TradeHistoryStateManagerProtocol {
    var state: TradeHistoryState { get }

    func resetData(_ pair: Pair)
    func fetchData(_ pair: Pair)
    func updateMarketListHeight(_ height: CGFloat)
}

class TradeHistoryCoordinator: NavCoordinator {
    var store = Store<TradeHistoryState>(
        reducer: tradeHistoryReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension TradeHistoryCoordinator: TradeHistoryCoordinatorProtocol {

}

extension TradeHistoryCoordinator: TradeHistoryStateManagerProtocol {
    var state: TradeHistoryState {
        return store.state
    }

    func resetData(_ pair: Pair) {
        Await.Queue.serialAsync.async {
            self.store.dispatch(FetchedFillOrderData(data: [], pair: pair))
        }
    }

    func fetchData(_ pair: Pair) {
        if CybexWebSocketService.shared.overload() {
            return
        }
        fetchFillOrders(with: pair, callback: {[weak self] (data) in
            guard let self = self else { return }

            Await.Queue.serialAsync.async {
                let result = JSON(data).arrayValue

                var convertedData: [JSON] = []

                for value in result {
                    convertedData.append([value["op"], value["time"]])
                }

                self.store.dispatch(FetchedFillOrderData(data: convertedData, pair: pair))
            }

        })
    }

    func fetchFillOrders(with pair: Pair, callback: CommonAnyCallback?) {
        let request = GetFillOrderHistoryRequest(pair: pair) { (response) in
            if let callback = callback {
                callback(response)
            }
        }

        CybexWebSocketService.shared.send(request: request)
    }

    func updateMarketListHeight(_ height: CGFloat) {
        if let vc = self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] as? MarketViewController, vc.pageContentViewHeight != nil, vc.pageContentViewHeight.constant != 550 {
            vc.pageContentViewHeight.constant = height + 50
        }
    }

}
