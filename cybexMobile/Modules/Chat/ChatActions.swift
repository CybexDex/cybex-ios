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

// MARK: - State
struct ChatState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)

    var messages: BehaviorRelay<[ChatCommonMessage]> = BehaviorRelay(value: [])
    var numberOfMember: BehaviorRelay<Int> = BehaviorRelay(value: 0)
}

// MARK: - Action
struct ChatFetchedAction: Action {
    var data: [ChatMessage]
}

struct ChatUpdateMemberAction: Action {
    var data: Int
}
