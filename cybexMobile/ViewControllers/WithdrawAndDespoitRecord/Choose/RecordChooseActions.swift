//
//  RecordChooseActions.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import HandyJSON

struct RecordChooseContext: RouteContext, HandyJSON {
    init() {}
}

// MARK: - State
struct RecordChooseState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data: BehaviorRelay<[String]?> = BehaviorRelay(value: nil)
}

// MARK: - Action
struct RecordChooseFetchedAction: ReSwift.Action {
    var data: JSON
}

struct FetchDataAction: ReSwift.Action {
    var data: [String]
}

struct FetchAccountAssetAction: ReSwift.Action {
    var data: AccountAssets
}
