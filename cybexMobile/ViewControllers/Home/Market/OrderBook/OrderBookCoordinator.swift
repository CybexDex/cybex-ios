//
//  OrderBookCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyJSON

protocol OrderBookCoordinatorProtocol {
}

protocol OrderBookStateManagerProtocol {
    var state: OrderBookState { get }

    func resetData(_ pair: Pair)

    func fetchData(_ pair: Pair)
    func updateMarketListHeight(_ height: CGFloat)
}

class OrderBookCoordinator: HomeRootCoordinator {
    var store = Store<OrderBookState>(
        reducer: orderBookReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension OrderBookCoordinator: OrderBookCoordinatorProtocol {

}

extension OrderBookCoordinator: OrderBookStateManagerProtocol {
    var state: OrderBookState {
        return store.state
    }

    func resetData(_ pair: Pair) {
        self.store.dispatch(FetchedLimitData(data: [], pair: pair))
    }

    func fetchData(_ pair: Pair) {
        if CybexWebSocketService.shared.overload() {
            return
        }

        fetchLimitOrders(with: pair, callback: {[weak self] (data) in
            guard let `self` = self else { return }

            if let data = data as? [LimitOrder] {
                self.store.dispatch(FetchedLimitData(data: data, pair: pair))
            }
        })
    }

    func fetchLimitOrders(with pair: Pair, callback: CommonAnyCallback?) {
        let request = GetLimitOrdersRequest(pair: pair) { response in
            if let callback = callback {
                callback(response)
            }
        }

        CybexWebSocketService.shared.send(request: request)
    }

    func updateMarketListHeight(_ height: CGFloat) {
        if let vc = self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] as? MarketViewController {
            vc.pageContentViewHeight.constant = height + 50
        }
    }
}
