//
//  WithdrawAddressActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct WithdrawAddressState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: WithdrawAddressPropertyState
    var callback: WithdrawAddressCallbackState
}

struct WithdrawAddressPropertyState {
    var data: BehaviorRelay<[WithdrawAddress]> = BehaviorRelay(value: [])
    var selectedAddress: BehaviorRelay<WithdrawAddress?> = BehaviorRelay(value: nil)
    var selectedAsset: BehaviorRelay<String?> = BehaviorRelay(value: "")
}

struct WithdrawAddressDataAction: Action {
    var data: [WithdrawAddress]
}

struct WithdrawAddressSelectDataAction: Action {
    var data: WithdrawAddress?
}

struct WithdrawAddressCallbackState {
}

struct SetSelectedAssetAction: Action {
    var asset: String
}
