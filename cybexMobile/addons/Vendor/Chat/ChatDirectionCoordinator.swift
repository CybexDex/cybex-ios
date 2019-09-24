//
//  ChatDirectionCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol ChatDirectionCoordinatorProtocol {
}

protocol ChatDirectionStateManagerProtocol {
    var state: ChatDirectionState { get }
    
    func switchPageState(_ state:PageState)
}

class ChatDirectionCoordinator: NavCoordinator {
    var store = Store(
        reducer: gChatDirectionReducer,
        state: nil,
        middleware:[trackingMiddleware]
    )
    
    var state: ChatDirectionState {
        return store.state
    }
    
    override class func start(_ root: BaseNavigationController, context:RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.chat.chatDirectionViewController()!
        let coordinator = ChatDirectionCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(ChatDirectionCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ChatDirectionStateManagerProtocol.self, observer: self)
    }
}

extension ChatDirectionCoordinator: ChatDirectionCoordinatorProtocol {
    
}

extension ChatDirectionCoordinator: ChatDirectionStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
