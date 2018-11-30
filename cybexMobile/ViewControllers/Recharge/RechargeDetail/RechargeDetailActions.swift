//
//  RechargeDetailActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift
import RxCocoa

// MARK: - State
struct RechargeDetailState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var data: BehaviorRelay<WithdrawinfoObject?> = BehaviorRelay(value: nil)
    var memoKey: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    var gatewayFee: BehaviorRelay<(Fee, success: Bool)?> = BehaviorRelay(value: nil)
    var memo: BehaviorRelay<String> = BehaviorRelay(value: "")
    var withdrawAddress: BehaviorRelay<WithdrawAddress?> = BehaviorRelay(value: nil)
}

struct FetchWithdrawInfo: Action {
    let data: WithdrawinfoObject
}

struct FetchWithdrawMemokey: Action {
    let data: String
}

struct FetchGatewayFee: Action {
    let data: (Fee, success: Bool)
}

struct SelectedAddressAction: Action {
    var data: WithdrawAddress
}
