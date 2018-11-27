//
//  ChatActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/11/8.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import HandyJSON
import ChatRoom

struct ChatContext: RouteContext, HandyJSON {
    var chanel: String = ""
    init() {}
}

enum ChatConnectState: String {
    case chatServiceDidClosed
    case chatServiceDidFail
    case chatServiceDidDisConnected
    case chatServiceDidConnected
    case chatServiceDidSend
}


// MARK: - State
struct ChatState: BaseState {
    
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)

    var messages: BehaviorRelay<[ChatCommonMessage]> = BehaviorRelay(value: [])
    var numberOfMember: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    var chatState: BehaviorRelay<ChatConnectState?> = BehaviorRelay(value: nil)
    
    var sendState: BehaviorRelay<ChatConnectState?> = BehaviorRelay(value: nil)
}

// MARK: - Action
struct ChatFetchedAction: Action {
    var data: [ChatMessage]
}

struct ChatUpdateMemberAction: Action {
    var data: Int
}

struct ChatConnectStateAcion: Action{
    var data: ChatConnectState
}

struct ChatSendStateAction: Action {
    var data: ChatConnectState
}
