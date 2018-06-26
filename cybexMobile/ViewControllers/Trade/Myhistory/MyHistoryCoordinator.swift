//
//  MyHistoryCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol MyHistoryCoordinatorProtocol {
}

protocol MyHistoryStateManagerProtocol {
    var state: MyHistoryState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<MyHistoryState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func filterFillOrder(_ pair:Pair) -> [FillOrder]
}

class MyHistoryCoordinator: TradeRootCoordinator {
    
    lazy var creator = MyHistoryPropertyActionCreate()
    
    var store = Store<MyHistoryState>(
        reducer: MyHistoryReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension MyHistoryCoordinator: MyHistoryCoordinatorProtocol {
    
}

extension MyHistoryCoordinator: MyHistoryStateManagerProtocol {
    var state: MyHistoryState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<MyHistoryState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
  
  func filterFillOrder(_ pair:Pair) -> [FillOrder]{
    if let fillOrders = UserManager.shared.fillOrder.value{
      return fillOrders
    }
  }
}
