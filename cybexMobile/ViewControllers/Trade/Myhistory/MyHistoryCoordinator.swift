//
//  MyHistoryCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol MyHistoryCoordinatorProtocol {
}

protocol MyHistoryStateManagerProtocol {
    var state: MyHistoryState { get }

}

class MyHistoryCoordinator: TradeRootCoordinator {
    var store = Store<MyHistoryState>(
        reducer: myHistoryReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension MyHistoryCoordinator: MyHistoryCoordinatorProtocol {

}

extension MyHistoryCoordinator: MyHistoryStateManagerProtocol {
    var state: MyHistoryState {
        return store.state
    }

}
