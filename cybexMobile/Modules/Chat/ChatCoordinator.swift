//
//  ChatCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import ChatRoom

protocol ChatCoordinatorProtocol {
    func connectChat()

    func send(_ message: String)
}

protocol ChatStateManagerProtocol {
    var state: ChatState { get }
    
    func switchPageState(_ state:PageState)
}

class ChatCoordinator: NavCoordinator {
    var store = Store(
        reducer: gChatReducer,
        state: nil,
        middleware:[trackingMiddleware]
    )
    
    var state: ChatState {
        return store.state
    }

    let service = ChatService()
    
    override class func start(_ root: BaseNavigationController, context:RouteContext? = nil) -> BaseViewController {
//        let vc = R.storyboard.chat.chatViewController()!
//        let coordinator = ChatCoordinator(rootVC: root)
//        vc.coordinator = coordinator
//        coordinator.store.dispatch(RouteContextAction(context: context))
        return BaseViewController()
    }

    override func register() {
        Broadcaster.register(ChatCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ChatStateManagerProtocol.self, observer: self)
    }
}

extension ChatCoordinator: ChatCoordinatorProtocol {
    func connectChat() {
        service.connect()
    }

    func send(_ message: String) {
        service.send(message)
    }

}

extension ChatCoordinator: ChatStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
