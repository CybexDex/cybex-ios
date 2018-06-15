//
//  TradeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol TradeCoordinatorProtocol {
  func openMyHistory()
}

protocol TradeStateManagerProtocol {
  var state: TradeState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TradeState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchData(_ pair : Pair)

}

class TradeCoordinator: TradeRootCoordinator {
  
  lazy var creator = TradePropertyActionCreate()
  
  var store = Store<TradeState>(
    reducer: TradeReducer,
    state: nil,
    middleware:[TrackingMiddleware]
  )
}

extension TradeCoordinator: TradeCoordinatorProtocol {
  func openMyHistory(){
    let vc = R.storyboard.business.myHistoryViewController()!
    let coordinator = MyHistoryCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
}

extension TradeCoordinator: TradeStateManagerProtocol {
  var state: TradeState {
    return store.state
  }
  
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TradeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
  
  
  func fetchData(_ pair:Pair) {
    let request = getLimitOrdersRequest(pair: pair) { response in
      if let data = response as? [LimitOrder] {
        self.store.dispatch(TradeFetchedLimitData(data:data, pair:pair))
      }
    }
    WebsocketService.shared.send(request: request)
  }
  
}
