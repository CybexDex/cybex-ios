//
//  AccountCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol AccountCoordinatorProtocol {
}

protocol AccountStateManagerProtocol {
    var state: AccountState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AccountState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class AccountCoordinator: NavCoordinator {
    
    lazy var creator = AccountPropertyActionCreate()
    
    var store = Store<AccountState>(
        reducer: AccountReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: AccountState {
        return store.state
    }
}

extension AccountCoordinator: AccountCoordinatorProtocol {
    
}

extension AccountCoordinator: AccountStateManagerProtocol {
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AccountState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
