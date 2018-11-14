//
//  TestCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/11/14.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol TestCoordinatorProtocol {
}

protocol TestStateManagerProtocol {
    var state: TestState { get }
    
    func switchPageState(_ state:PageState)
}

class TestCoordinator: NavCoordinator {
    var store = Store(
        reducer: TestReducer,
        state: nil,
        middleware:[trackingMiddleware]
    )
    
    var state: TestState {
        return store.state
    }
    
    override class func start(_ root: BaseNavigationController, context:RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.chat.testViewController()!
        let coordinator = TestCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(TestCoordinatorProtocol.self, observer: self)
        Broadcaster.register(TestStateManagerProtocol.self, observer: self)
    }
}

extension TestCoordinator: TestCoordinatorProtocol {
    
}

extension TestCoordinator: TestStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
