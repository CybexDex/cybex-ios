//
//  MyHistoryActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct MyHistoryState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var fillOrders: BehaviorRelay<[LimitOrderStatus]> = BehaviorRelay(value: [])
}

struct FillOrderDataFetchedAction: Action {
    var data: [LimitOrderStatus]
}
