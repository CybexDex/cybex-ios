//
//  TransferAddressHomeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct TransferAddressHomeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: TransferAddressHomePropertyState
    var callback: TransferAddressHomeCallbackState
}

struct TransferAddressHomePropertyState {
    var data: BehaviorRelay<[TransferAddress]> = BehaviorRelay(value: [])
    var selectedAddress: BehaviorRelay<TransferAddress?> = BehaviorRelay(value: nil)
}

struct TransferAddressHomeDataAction: Action {
    var data: [TransferAddress]
}

struct TransferAddressSelectDataAction: Action {
    var data: TransferAddress?
}

struct TransferAddressHomeCallbackState {
}
