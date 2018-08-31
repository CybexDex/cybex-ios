//
//  ETODetailCoordinator.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETODetailCoordinatorProtocol {
}

protocol ETODetailStateManagerProtocol {
    var state: ETODetailState { get }
    
    func switchPageState(_ state:PageState)
}

class ETODetailCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETODetailReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETODetailState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETODetailCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETODetailStateManagerProtocol.self, observer: self)
    }
}

extension ETODetailCoordinator: ETODetailCoordinatorProtocol {
    
}

extension ETODetailCoordinator: ETODetailStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
