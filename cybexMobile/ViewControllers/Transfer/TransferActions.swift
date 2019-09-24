//
//  TransferActions.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
enum AccountValidStatus: Int {
    case unValided = 0
    case validSuccessed
    case validFailed
    case validding
}

struct TransferState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)

    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var accountValid: BehaviorRelay<AccountValidStatus> = BehaviorRelay(value: .unValided)

    var amountValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    var balance: BehaviorRelay<Balance?> = BehaviorRelay(value: nil) // 币种

    var fee: BehaviorRelay<Fee?> = BehaviorRelay(value: nil)

    var amount: BehaviorRelay<String> = BehaviorRelay(value: "")
    var memo: BehaviorRelay<String> = BehaviorRelay(value: "")

    var account: BehaviorRelay<String> = BehaviorRelay(value: "")
    var toAccount: BehaviorRelay<Account?> = BehaviorRelay(value: nil)
}

struct ValidAccountAction: ReSwift.Action {
    var status: AccountValidStatus = .unValided
}

struct ValidAmountAction: ReSwift.Action {
    var isValid: Bool = false
}

struct SetBalanceAction: ReSwift.Action {
    let balance: Balance
}

struct SetFeeAction: ReSwift.Action {
    let fee: Fee
}

struct SetToAccountAction: ReSwift.Action {
    let account: Account?
}

struct ResetDataAction: ReSwift.Action {

}

struct CleanToAccountAction: ReSwift.Action {

}

struct ChooseAccountAction: ReSwift.Action {
    var account: TransferAddress
}
