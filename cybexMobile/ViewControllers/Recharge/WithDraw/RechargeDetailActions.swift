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

    var data: BehaviorRelay<WithdrawinfoObject?> = BehaviorRelay(value: nil) // 提现网关相关信息
    var memoKey: BehaviorRelay<String?> = BehaviorRelay(value: nil) // 提现网关memo公钥
    var fee: BehaviorRelay<(Fee, success: Bool)?> = BehaviorRelay(value: nil)
    var memo: BehaviorRelay<String> = BehaviorRelay(value: "")
    var withdrawAddress: BehaviorRelay<WithdrawAddress?> = BehaviorRelay(value: nil)
    var withdrawMsgInfo: BehaviorRelay<RechageWordVMData?> = BehaviorRelay(value: nil)
}

struct FetchWithdrawInfo: Action {
    let data: WithdrawinfoObject
}

struct FetchWithdrawMemokey: Action {
    let data: String
}

struct FetchCybexFee: Action {
    let data: (Fee, success: Bool)
}

struct SelectedAddressAction: Action {
    var data: WithdrawAddress
}

struct FetchWithdrawWordInfo: Action {
    var data: RechargeWorldInfo
}
