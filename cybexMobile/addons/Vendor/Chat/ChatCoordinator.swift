//
//  ChatCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import ChatRoom
import Reachability

protocol ChatCoordinatorProtocol {
    func connectChat(_ channel: String)
    func disconnect()

    func send(_ message: String, username: String, sign: String)
    
    func resetRefreshMessage(_ isRefresh: Bool)
    
    func loginSuccessReloadData(_ sender: [ChatCommonMessage])
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

    lazy var disconnectDispatch = debounce(delay: .seconds(AppConfiguration.debounceDisconnectTime), action: {
        if !AppHelper.shared.infront {
            self.service.disconnect()
        }
    })

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
            // MARK: 元祖判断
            if self.state.refreshMessage.value == true {
                self.store.dispatch(ChatFetchedAction(data: messages,isRefresh: true))
                self.resetRefreshMessage(false)
            }
            else {
                self.store.dispatch(ChatFetchedAction(data: messages,isRefresh: false))
            }
        })
        
        service.provider.onlineUpdated.delegate(on: self, block: { (self, numberOfMember) in
            self.store.dispatch(ChatUpdateMemberAction(data: numberOfMember))
        })
        
        service.provider.refreshMessageReceived.delegate(on: self) { (self, _) in
            self.resetRefreshMessage(true)
        }
        
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
                if self.rootVC.topViewController is ChatViewController {
                    self.service.reconnect()
                }
            case .none:
                self.service.disconnect()
                break
            case .unavailable:
                break
            }

        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            if self.rootVC.topViewController is ChatViewController {
                self.service.reconnect()
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.disconnectDispatch()
        }
    }
    
    

    func disconnect() {
        service.disconnect()
    }

    func send(_ message: String, username: String, sign: String) {
        service.send(service.provider.message(username, msg: message, sign: sign))
    }
    
    func resetRefreshMessage(_ isRefresh: Bool) {
        self.store.dispatch(ChatRefreshAction(data: isRefresh))
    }
    
    func loginSuccessReloadData(_ sender: [ChatCommonMessage]) {
        guard let userName = UserManager.shared.name.value else { return }
        let data = sender.map { (message) -> ChatCommonMessage in
            if message.sender.displayName == userName {
                if case let .attributedText(attr) = message.kind,
                    let name = attr.string.components(separatedBy: " ").first,
                    let substring = attr.string.substring(from: name.count + 1,
                                                          length: attr.string.count - name.count) {
                    let nameAttribute = nameAttributeString(name, isRealName: true)
                    let messageAttribute = messageAttributeString(" " + substring)
                    let attributedText = NSMutableAttributedString(attributedString: nameAttribute)
                    attributedText.append(messageAttribute)
                   return ChatCommonMessage(attributedText: attributedText, sender: Sender(id: "101010", displayName: userName), messageId: "\(message.messageId)", date: message.sentDate)
                }
            }
            return message
        }
        self.store.dispatch(ChatReloadDataAction(data: data))
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
