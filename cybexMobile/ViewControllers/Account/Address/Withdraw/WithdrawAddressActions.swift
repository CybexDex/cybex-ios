//
//  WithdrawAddressActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct WithdrawAddressState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: WithdrawAddressPropertyState
    var callback: WithdrawAddressCallbackState
}

struct WithdrawAddressPropertyState {
}

struct WithdrawAddressCallbackState {
}

//MARK: - Action Creator
class WithdrawAddressPropertyActionCreate {
    public typealias ActionCreator = (_ state: WithdrawAddressState, _ store: Store<WithdrawAddressState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: WithdrawAddressState,
        _ store: Store <WithdrawAddressState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
