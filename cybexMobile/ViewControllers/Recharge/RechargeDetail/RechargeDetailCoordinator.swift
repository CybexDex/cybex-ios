//
//  RechargeDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol RechargeDetailCoordinatorProtocol {
}

protocol RechargeDetailStateManagerProtocol {
    var state: RechargeDetailState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeDetailState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class RechargeDetailCoordinator: AccountRootCoordinator {
    
    lazy var creator = RechargeDetailPropertyActionCreate()
    
    var store = Store<RechargeDetailState>(
        reducer: RechargeDetailReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension RechargeDetailCoordinator: RechargeDetailCoordinatorProtocol {
  
}

extension RechargeDetailCoordinator: RechargeDetailStateManagerProtocol {
    var state: RechargeDetailState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeDetailState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
