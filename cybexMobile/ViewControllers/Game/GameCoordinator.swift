//
//  GameCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/12/7.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol GameCoordinatorProtocol {
}

protocol GameStateManagerProtocol {
    var state: GameState { get }
    
    func switchPageState(_ state:PageState)
}

class GameCoordinator: NavCoordinator {
    var store = Store(
        reducer: gGameReducer,
        state: nil,
        middleware:[trackingMiddleware]
    )
    
    var state: GameState {
        return store.state
    }
    
    override class func start(_ root: BaseNavigationController, context:RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.main.gameViewController()!
        let coordinator = GameCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(GameCoordinatorProtocol.self, observer: self)
        Broadcaster.register(GameStateManagerProtocol.self, observer: self)
    }
}

extension GameCoordinator: GameCoordinatorProtocol {
    
}

extension GameCoordinator: GameStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
