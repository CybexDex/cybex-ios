//
//  WithdrawAddressHomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol WithdrawAddressHomeCoordinatorProtocol {
}

protocol WithdrawAddressHomeStateManagerProtocol {
    var state: WithdrawAddressHomeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressHomeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class WithdrawAddressHomeCoordinator: AccountRootCoordinator {
    lazy var creator = WithdrawAddressHomePropertyActionCreate()

    var store = Store<WithdrawAddressHomeState>(
        reducer: WithdrawAddressHomeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
        
    override func register() {
        Broadcaster.register(WithdrawAddressHomeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAddressHomeStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAddressHomeCoordinator: WithdrawAddressHomeCoordinatorProtocol {
    
}

extension WithdrawAddressHomeCoordinator: WithdrawAddressHomeStateManagerProtocol {
    var state: WithdrawAddressHomeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressHomeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
