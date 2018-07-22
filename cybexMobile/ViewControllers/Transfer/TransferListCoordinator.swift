//
//  TransferListCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol TransferListCoordinatorProtocol {
}

protocol TransferListStateManagerProtocol {
    var state: TransferListState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferListState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class TransferListCoordinator: <#RootCoordinator#> {
    
    lazy var creator = TransferListPropertyActionCreate()
    
    var store = Store<TransferListState>(
        reducer: TransferListReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension TransferListCoordinator: TransferListCoordinatorProtocol {
    
}

extension TransferListCoordinator: TransferListStateManagerProtocol {
    var state: TransferListState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferListState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
