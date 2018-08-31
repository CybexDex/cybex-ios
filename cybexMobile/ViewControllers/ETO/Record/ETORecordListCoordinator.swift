//
//  ETORecordListCoordinator.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETORecordListCoordinatorProtocol {
}

protocol ETORecordListStateManagerProtocol {
    var state: ETORecordListState { get }
}

class ETORecordListCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETORecordListReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETORecordListState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETORecordListCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETORecordListStateManagerProtocol.self, observer: self)
    }
}

extension ETORecordListCoordinator: ETORecordListCoordinatorProtocol {
    
}

extension ETORecordListCoordinator: ETORecordListStateManagerProtocol {
    
}
