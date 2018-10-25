//
//  WithdrawAddressHomeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct WithdrawAddressHomeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: WithdrawAddressHomePropertyState
    var callback: WithdrawAddressHomeCallbackState
}

struct WithdrawAddressHomeViewModel {
    var imageURLString: String = ""
    var count: BehaviorRelay<String> = BehaviorRelay(value: "")
    var name: String = ""
    var model: Trade = Trade()
}

struct WithdrawAddressHomePropertyState {
    typealias WithdrawAddressHomeData = (viewModel: WithdrawAddressHomeViewModel, addressData: [WithdrawAddress])

    var data: BehaviorRelay<[WithdrawAddressHomeViewModel]> = BehaviorRelay(value: [])
    var selectedViewModel: BehaviorRelay<WithdrawAddressHomeData?> = BehaviorRelay(value: nil)
    var addressData: BehaviorRelay<[String: [WithdrawAddress]]> = BehaviorRelay(value: [:])
}

struct WithdrawAddressHomeSelectedAction: Action {
    var index: Int
}

struct WithdrawAddressHomeAddressDataAction: Action {
    var data: [String: [WithdrawAddress]]
}

struct WithdrawAddressHomeCallbackState {
}

// MARK: - Action Creator
class WithdrawAddressHomePropertyActionCreate {
    public typealias ActionCreator = (_ state: WithdrawAddressHomeState, _ store: Store<WithdrawAddressHomeState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: WithdrawAddressHomeState,
        _ store: Store <WithdrawAddressHomeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
