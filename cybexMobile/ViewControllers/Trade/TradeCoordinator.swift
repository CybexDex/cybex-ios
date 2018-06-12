//
//  TradeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol TradeCoordinatorProtocol {
}

protocol TradeStateManagerProtocol {
    var state: TradeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TradeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class TradeCoordinator: TradeRootCoordinator {
    
    lazy var creator = TradePropertyActionCreate()
    
    var store = Store<TradeState>(
        reducer: TradeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension TradeCoordinator: TradeCoordinatorProtocol {
    
}

extension TradeCoordinator: TradeStateManagerProtocol {
    var state: TradeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TradeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
