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
struct BusinessState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: BusinessPropertyState
}

struct BusinessPropertyState {
    var price: BehaviorRelay<String> = BehaviorRelay(value: "")
    var amount: BehaviorRelay<String> = BehaviorRelay(value: "")

    var fee_amount: BehaviorRelay<Decimal> = BehaviorRelay(value: Decimal(floatLiteral: 0))
    var feeID: BehaviorRelay<String> = BehaviorRelay(value: "")

    var balance: BehaviorRelay<Decimal> = BehaviorRelay(value: Decimal(floatLiteral: 0))
}

struct changePriceAction: Action {
    var price: String
}

struct ChangeAmountAction: Action {
    var amount: String
}

struct adjustPriceAction: Action {
    var plus: Bool
    var pricision: Int
}

struct feeFetchedAction: Action {
    var success: Bool
    var amount: Decimal
    var assetID: String
}

struct BalanceFetchedAction: Action {
    var amount: Decimal
}

struct switchPercentAction: Action {
    var amount: Decimal
    var pricision: Int
}

struct resetTrade: Action {
}

// MARK: - Action Creator
class BusinessPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: BusinessState, _ store: Store<BusinessState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: BusinessState,
        _ store: Store <BusinessState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
