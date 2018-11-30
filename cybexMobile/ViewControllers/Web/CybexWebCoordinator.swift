//
//  CybexWebCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol CybexWebCoordinatorProtocol {
}

protocol CybexWebStateManagerProtocol {
    var state: CybexWebState { get }

    func switchPageState(_ state: PageState)
}

class CybexWebCoordinator: NavCoordinator {
    var store = Store(
        reducer: cybexWebReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: CybexWebState {
        return store.state
    }

    override func register() {
        Broadcaster.register(CybexWebCoordinatorProtocol.self, observer: self)
        Broadcaster.register(CybexWebStateManagerProtocol.self, observer: self)
    }
}

extension CybexWebCoordinator: CybexWebCoordinatorProtocol {

}

extension CybexWebCoordinator: CybexWebStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
