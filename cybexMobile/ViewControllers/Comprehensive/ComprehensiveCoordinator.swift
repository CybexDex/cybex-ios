//
//  ComprehensiveCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter
import Async

protocol ComprehensiveCoordinatorProtocol {
}

protocol ComprehensiveStateManagerProtocol {
    var state: ComprehensiveState { get }
    
    func switchPageState(_ state:PageState)
}

class ComprehensiveCoordinator: ComprehensiveRootCoordinator {
    var store = Store(
        reducer: ComprehensiveReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ComprehensiveState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ComprehensiveCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ComprehensiveStateManagerProtocol.self, observer: self)
    }
}

extension ComprehensiveCoordinator: ComprehensiveCoordinatorProtocol {
    
}

extension ComprehensiveCoordinator: ComprehensiveStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        Async.main {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
