//
//  LockupAssetsCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol LockupAssetsCoordinatorProtocol {

}

protocol LockupAssetsStateManagerProtocol {
    var state: LockupAssetsState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<LockupAssetsState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class LockupAssetsCoordinator: AccountRootCoordinator {
    lazy var creator = LockupAssetsPropertyActionCreate()
    
    var store = Store<LockupAssetsState>(
        reducer: LockupAssetsReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension LockupAssetsCoordinator: LockupAssetsCoordinatorProtocol {
    
}

extension LockupAssetsCoordinator: LockupAssetsStateManagerProtocol {
    var state: LockupAssetsState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<LockupAssetsState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
