//
//  RechargeRecodeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct RechargeRecodeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var data: BehaviorRelay<TradeRecord?> = BehaviorRelay(value: nil)
    var asset: String = ""
    var explorers: BehaviorRelay<[BlockExplorer]?> = BehaviorRelay(value: nil)
}

struct FetchDepositRecordsAction: Action {
    var data: TradeRecord?
}

struct SetWithdrawListAssetAction: Action {
    var asset: String
}

struct FetchAssetUrlAction: Action {
    var data: [BlockExplorer]
}
