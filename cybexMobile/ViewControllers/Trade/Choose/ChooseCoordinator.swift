//
//  ChooseCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol ChooseCoordinatorProtocol {
}

protocol ChooseStateManagerProtocol {
    var state: ChooseState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<ChooseState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class ChooseCoordinator: TradeRootCoordinator {
    
    lazy var creator = ChoosePropertyActionCreate()
    
    var store = Store<ChooseState>(
        reducer: ChooseReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension ChooseCoordinator: ChooseCoordinatorProtocol {
    
}

extension ChooseCoordinator: ChooseStateManagerProtocol {
    var state: ChooseState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<ChooseState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
