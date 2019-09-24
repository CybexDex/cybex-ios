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
struct TransferAddressHomeState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var data: BehaviorRelay<[TransferAddress]> = BehaviorRelay(value: [])
    var selectedAddress: BehaviorRelay<TransferAddress?> = BehaviorRelay(value: nil)
}

struct TransferAddressHomeDataAction: ReSwift.Action {
    var data: [TransferAddress]
}

struct TransferAddressSelectDataAction: ReSwift.Action {
    var data: TransferAddress?
}
