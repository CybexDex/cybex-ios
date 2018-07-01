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
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TradeHistoryState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func resetData()
  func fetchData(_ pair:Pair)
  func updateMarketListHeight(_ height:CGFloat)
}

class TradeHistoryCoordinator: HomeRootCoordinator {
    
    lazy var creator = TradeHistoryPropertyActionCreate()
    
    var store = Store<TradeHistoryState>(
        reducer: TradeHistoryReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension TradeHistoryCoordinator: TradeHistoryCoordinatorProtocol {
    
}

extension TradeHistoryCoordinator: TradeHistoryStateManagerProtocol {
    var state: TradeHistoryState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TradeHistoryState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
  
  func resetData() {
    self.store.dispatch(FetchedFillOrderData(data:[]))
  }
  
  func fetchData(_ pair:Pair) {
    store.dispatch(creator.fetchFillOrders(with: pair, callback: {[weak self] (data) in
      guard let `self` = self else { return }
      
      if let data = data as? [JSON] {
        self.store.dispatch(FetchedFillOrderData(data:data))
      }
    }))
  }
  
  func updateMarketListHeight(_ height:CGFloat) {
    if let vc = self.rootVC.viewControllers[self.rootVC.viewControllers.count - 1] as? MarketViewController {
      vc.pageContentViewHeight.constant = height + 50
    }
    
  }
    
}
