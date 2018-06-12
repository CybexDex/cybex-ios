//
//  WithdrawDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol WithdrawDetailCoordinatorProtocol {
}

protocol WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawDetailState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class WithdrawDetailCoordinator: AccountRootCoordinator {
    
    lazy var creator = WithdrawDetailPropertyActionCreate()
    
    var store = Store<WithdrawDetailState>(
        reducer: WithdrawDetailReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension WithdrawDetailCoordinator: WithdrawDetailCoordinatorProtocol {
    
}

extension WithdrawDetailCoordinator: WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawDetailState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
