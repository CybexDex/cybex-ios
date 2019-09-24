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

    var messages: BehaviorRelay<([ChatCommonMessage], isRefresh: Bool)> = BehaviorRelay(value: ([], isRefresh: false))
    var numberOfMember: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    var chatState: BehaviorRelay<ChatConnectState?> = BehaviorRelay(value: nil)
    
    var sendState: BehaviorRelay<ChatConnectState?> = BehaviorRelay(value: nil)
    
    var refreshMessage: BehaviorRelay<Bool> = BehaviorRelay(value: false)
}

// MARK: - Action
struct ChatFetchedAction: ReSwift.Action {
    var data: [ChatMessage]
    var isRefresh: Bool = false
}

struct ChatRefreshAction: ReSwift.Action {
    var data: Bool = false
}

struct ChatUpdateMemberAction: ReSwift.Action {
    var data: Int
}

struct ChatConnectStateAcion: ReSwift.Action{
    var data: ChatConnectState
}

struct ChatSendStateAction: ReSwift.Action {
    var data: ChatConnectState
}

struct ChatReloadDataAction: ReSwift.Action {
    var data: [ChatCommonMessage]
}


