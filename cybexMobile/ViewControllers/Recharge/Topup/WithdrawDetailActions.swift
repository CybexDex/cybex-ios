//
//  WithdrawDetailActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import RxSwift

// MARK: - State
struct WithdrawDetailState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var data: BehaviorRelay<AccountAddressRecord?> = BehaviorRelay(value: nil)
    var msgInfo: BehaviorRelay<RechageWordVMData?> = BehaviorRelay(value: nil)
}

struct FetchAddressInfo: ReSwift.Action {
    let data: AccountAddressRecord
}

struct FetchMsgInfo: ReSwift.Action {
    var data: RechargeWorldInfo
}
