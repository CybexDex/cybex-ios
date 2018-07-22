//
//  WithdrawRecodeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol WithdrawRecodeCoordinatorProtocol {
}

protocol WithdrawRecodeStateManagerProtocol {
    var state: WithdrawRecodeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawRecodeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class WithdrawRecodeCoordinator: AccountRootCoordinator {
    
    lazy var creator = WithdrawRecodePropertyActionCreate()
    
    var store = Store<WithdrawRecodeState>(
        reducer: WithdrawRecodeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension WithdrawRecodeCoordinator: WithdrawRecodeCoordinatorProtocol {
    
}

extension WithdrawRecodeCoordinator: WithdrawRecodeStateManagerProtocol {
    var state: WithdrawRecodeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawRecodeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
