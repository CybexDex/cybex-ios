//
//  AddressHomeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct AddressHomeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: AddressHomePropertyState
    var callback: AddressHomeCallbackState
}

struct AddressHomePropertyState {
}

struct AddressHomeCallbackState {
}

// MARK: - Action Creator
class AddressHomePropertyActionCreate {
    public typealias ActionCreator = (_ state: AddressHomeState, _ store: Store<AddressHomeState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: AddressHomeState,
        _ store: Store <AddressHomeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
