//
//  TestActions.swift
//  cybexMobile
//
//  Created DKM on 2018/11/14.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import HandyJSON

struct TestContext: RouteContext, HandyJSON {
    init() {}
    
}

//MARK: - State
struct TestState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
struct TestFetchedAction: Action {
    var data:JSON
}
