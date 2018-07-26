//
//  RechargeRecodeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol RechargeRecodeCoordinatorProtocol {
}

protocol RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeRecodeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchRechargeRecodeList()

}

class RechargeRecodeCoordinator: AccountRootCoordinator {
    
    lazy var creator = RechargeRecodePropertyActionCreate()
    
    var store = Store<RechargeRecodeState>(
        reducer: RechargeRecodeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension RechargeRecodeCoordinator: RechargeRecodeCoordinatorProtocol {
    
}

extension RechargeRecodeCoordinator: RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeRecodeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
  
  func fetchRechargeRecodeList() {
    
  }
    
}
