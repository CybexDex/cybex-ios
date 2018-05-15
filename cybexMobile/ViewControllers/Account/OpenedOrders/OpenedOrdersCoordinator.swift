//
//  OpenedOrdersCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//  路由文件。  跳转/业务处理

import UIKit
import ReSwift

// 跳转
protocol OpenedOrdersCoordinatorProtocol {
}
// 业务处理
protocol OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<OpenedOrdersState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
 
}

class OpenedOrdersCoordinator: SettingRootCoordinator {
    
    lazy var creator = OpenedOrdersPropertyActionCreate()
    
    var store = Store<OpenedOrdersState>(
        reducer: OpenedOrdersReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension OpenedOrdersCoordinator: OpenedOrdersCoordinatorProtocol {
    
}

extension OpenedOrdersCoordinator: OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<OpenedOrdersState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
