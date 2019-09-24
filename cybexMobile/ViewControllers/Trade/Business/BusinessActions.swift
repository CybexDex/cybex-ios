//
//  BusinessActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import RxSwift

// MARK: - State
struct BusinessState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var price: BehaviorRelay<String> = BehaviorRelay(value: "")
    var amount: BehaviorRelay<String> = BehaviorRelay(value: "")

    var feeAmount: BehaviorRelay<Decimal> = BehaviorRelay(value: Decimal(floatLiteral: 0))
    var feeID: BehaviorRelay<String> = BehaviorRelay(value: "")

    var balance: BehaviorRelay<Decimal> = BehaviorRelay(value: Decimal(floatLiteral: 0))
}

struct ChangePriceAction: ReSwift.Action {
    var price: String
}

struct ChangeAmountAction: ReSwift.Action {
    var amount: String
}

struct AdjustPriceAction: ReSwift.Action {
    var plus: Bool
    var pricision: Int
}

struct FeeFetchedAction: ReSwift.Action {
    var success: Bool
    var amount: Decimal
    var assetID: String
}

struct BalanceFetchedAction: ReSwift.Action {
    var amount: Decimal
}

struct SwitchPercentAction: ReSwift.Action {
    var amount: Decimal
    var pricision: Int
}

struct ResetTrade: ReSwift.Action {
}
