//
//  YourPortfolioCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol YourPortfolioCoordinatorProtocol {
}

protocol YourPortfolioStateManagerProtocol {
    var state: YourPortfolioState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<YourPortfolioState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class YourPortfolioCoordinator: AccountRootCoordinator {
    
    lazy var creator = YourPortfolioPropertyActionCreate()
    
    var store = Store<YourPortfolioState>(
        reducer: YourPortfolioReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension YourPortfolioCoordinator: YourPortfolioCoordinatorProtocol {
    
}

extension YourPortfolioCoordinator: YourPortfolioStateManagerProtocol {
    var state: YourPortfolioState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<YourPortfolioState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
