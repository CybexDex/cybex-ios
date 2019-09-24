//
//  AddAddressActions.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct AddAddressState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var asset: BehaviorRelay<String> = BehaviorRelay(value: "")
    var address: BehaviorRelay<String> = BehaviorRelay(value: "")
    var note: BehaviorRelay<String> = BehaviorRelay(value: "")
    var memo: BehaviorRelay<String> = BehaviorRelay(value: "")

    var addressVailed: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var noteVailed: BehaviorRelay<Bool> = BehaviorRelay(value: false)
}

struct VerificationNoteAction: ReSwift.Action {
    var data: Bool
}

struct SetAssetAction: ReSwift.Action {
    var data: String
}

struct VerificationAddressAction: ReSwift.Action {
    var success: Bool
}

struct SetNoteAction: ReSwift.Action {
    var data: String
}

struct SetAddressAction: ReSwift.Action {
    var data: String
}
