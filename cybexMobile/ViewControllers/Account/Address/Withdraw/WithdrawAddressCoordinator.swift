//
//  WithdrawAddressCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol WithdrawAddressCoordinatorProtocol {
}

protocol WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class WithdrawAddressCoordinator: AccountRootCoordinator {
    lazy var creator = WithdrawAddressPropertyActionCreate()

    var store = Store<WithdrawAddressState>(
        reducer: WithdrawAddressReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
        
    override func register() {
        Broadcaster.register(WithdrawAddressCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAddressStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAddressCoordinator: WithdrawAddressCoordinatorProtocol {
    
}

extension WithdrawAddressCoordinator: WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
