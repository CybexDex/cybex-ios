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
    func connectChat(_ channel: String)
    func disconnect()

    func send(_ message: String, username: String, sign: String)
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

    let service = ChatService(FCUUID.uuid())
    
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
    func connectChat(_ channel: String) {
        service.messageReceived = {[weak self] messages in
            guard let self = self else { return }
            self.store.dispatch(ChatFetchedAction(data: messages))
        }
        service.connect(channel)
    }

    func disconnect() {
        service.disconnect()
    }

    func send(_ message: String, username: String, sign: String) {
        service.send(service.provider.message(username, msg: message, sign: sign))
    }
}

extension ChatCoordinator: ChatStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
