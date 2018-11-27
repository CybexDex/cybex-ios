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
import Reachability

protocol ChatCoordinatorProtocol {
    func connectChat(_ channel: String)
    func disconnect()

    func send(_ message: String, username: String, sign: String)
}

protocol ChatStateManagerProtocol {
    var state: ChatState { get }
    
    func switchPageState(_ state:PageState)
    
    func openNewMessageVC(_ sender: UIView)
    
    func openNameVC(_ sender: UIView, name: String)
}

class ChatCoordinator: NavCoordinator {
    var store = Store(
        reducer: gChatReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var state: ChatState {
        return store.state
    }

    let service = ChatService(UIDevice.current.uuid())

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {


        return BaseViewController()
    }

    override func register() {
        Broadcaster.register(ChatCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ChatStateManagerProtocol.self, observer: self)
    }
}

extension Notification.Name {
    public static let LineSDKAccessTokenDidUpdate = Notification.Name("com.linecorp.linesdk.AccessTokenDidUpdate")
}

extension ChatCoordinator: ChatCoordinatorProtocol {
    func connectChat(_ channel: String) {
        service.provider.messageReceived.delegate(on: self, block: { (self, messages) in
            self.store.dispatch(ChatFetchedAction(data: messages))
        })
        
        service.provider.onlineUpdated.delegate(on: self, block: { (self, numberOfMember) in
            self.store.dispatch(ChatUpdateMemberAction(data: numberOfMember))
        })
        
        service.chatServiceDidDisConnected.delegate(on: self) { (self, _) in
            self.store.dispatch(ChatConnectStateAcion(data: ChatConnectState.chatServiceDidDisConnected))
        }
        service.chatServiceDidFail.delegate(on: self) { (self, _) in
            self.store.dispatch(ChatConnectStateAcion(data: ChatConnectState.chatServiceDidFail))
        }
        service.chatServiceDidClosed.delegate(on: self) { (self, _) in
            self.store.dispatch(ChatConnectStateAcion(data: ChatConnectState.chatServiceDidClosed))
        }
        service.chatServiceDidConnected.delegate(on: self) { (self, _) in
            self.store.dispatch(ChatConnectStateAcion(data: ChatConnectState.chatServiceDidConnected))
            self.monitorService()
        }
        service.chatServiceDidSended.delegate(on: self) { (self, _) in
            self.store.dispatch(ChatSendStateAction(data: ChatConnectState.chatServiceDidSend))
        }
        
        service.connect(channel)
    }

    func monitorService() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }

            switch reachability.connection {
            case .wifi, .cellular:
                self.service.reconnect()
            case .none:
                self.service.disconnect()
                break
            }

        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            self.service.reconnect()
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.service.disconnect()
        }
    }
    
    

    func disconnect() {
        service.disconnect()
    }

    func send(_ message: String, username: String, sign: String) {
        service.send(service.provider.message(username, msg: message, sign: sign))
    }
}

extension ChatCoordinator: ChatStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
    
    func openNewMessageVC(_ sender: UIView) {

    }
    
    func openNameVC(_ sender: UIView, name: String) {
        self.createChatDirectionVC(sender, direction: .unknown, type: ChatDirectionViewController.ChatDirectionType.icon, name: name)
    }
    
    func createChatDirectionVC(_ sender: UIView, direction: UIPopoverArrowDirection, type: ChatDirectionViewController.ChatDirectionType, name: String) {
        guard let vc = R.storyboard.chat.chatDirectionViewController(), let mainVC = self.rootVC.topViewController as? ChatViewController else { return }
        vc.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 45)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = sender
        vc.popoverPresentationController?.sourceRect = sender.bounds
        vc.popoverPresentationController?.delegate = mainVC
        vc.popoverPresentationController?.permittedArrowDirections = direction
        vc.popoverPresentationController?.theme_backgroundColor = [UIColor.darkFour.hexString(true), UIColor.paleGrey.hexString(true)]
        vc.viewType = type
        vc.delegate = mainVC
        vc.name = name
        vc.coordinator = ChatDirectionCoordinator(rootVC: self.rootVC)
        mainVC.present(vc, animated: true) {
            mainVC.view.superview?.cornerRadius = 4
        }
    }
}
