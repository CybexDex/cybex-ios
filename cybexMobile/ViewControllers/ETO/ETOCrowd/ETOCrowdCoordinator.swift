//
//  ETOCrowdCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETOCrowdCoordinatorProtocol {
}

protocol ETOCrowdStateManagerProtocol {
    var state: ETOCrowdState { get }
    
    func switchPageState(_ state:PageState)
}

class ETOCrowdCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOCrowdReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETOCrowdState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETOCrowdCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOCrowdStateManagerProtocol.self, observer: self)
    }
}

extension ETOCrowdCoordinator: ETOCrowdCoordinatorProtocol {
    
}

extension ETOCrowdCoordinator: ETOCrowdStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
