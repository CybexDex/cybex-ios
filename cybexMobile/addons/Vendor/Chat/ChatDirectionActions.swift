//
//  ChatDirectionActions.swift
//  cybexMobile
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import HandyJSON

struct ChatDirectionContext: RouteContext, HandyJSON {
    init() {}
    
}

//MARK: - State
struct ChatDirectionState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
struct ChatDirectionFetchedAction: ReSwift.Action {
    var data:JSON
}
