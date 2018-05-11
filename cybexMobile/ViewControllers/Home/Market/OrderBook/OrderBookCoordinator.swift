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
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<OrderBookState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchData(_ pair:Pair)
  func updateMarketListHeight(_ height:CGFloat)
}

class OrderBookCoordinator: HomeRootCoordinator {
    
    lazy var creator = OrderBookPropertyActionCreate()
    
    var store = Store<OrderBookState>(
        reducer: OrderBookReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension OrderBookCoordinator: OrderBookCoordinatorProtocol {
    
}

extension OrderBookCoordinator: OrderBookStateManagerProtocol {
    var state: OrderBookState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<OrderBookState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
  
  func fetchData(_ pair:Pair) {
    store.dispatch(creator.fetchLimitOrders(with: pair, callback: {[weak self] (data) in
      guard let `self` = self else { return }

      if let data = data as? [LimitOrder] {
        self.store.dispatch(FetchedLimitData(data:data, pair:pair))
      }
    }))
  }
  
  func updateMarketListHeight(_ height:CGFloat) {
    if let vc = self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] as? MarketViewController {
      vc.pageContentViewHeight.constant = height + 40
    }
  }

}
