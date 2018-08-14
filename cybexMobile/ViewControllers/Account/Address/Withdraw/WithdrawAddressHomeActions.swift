//
//  WithdrawAddressHomeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct WithdrawAddressHomeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: WithdrawAddressHomePropertyState
    var callback: WithdrawAddressHomeCallbackState
}

struct WithdrawAddressHomePropertyState {
}

struct WithdrawAddressHomeCallbackState {
}

//MARK: - Action Creator
class WithdrawAddressHomePropertyActionCreate {
    public typealias ActionCreator = (_ state: WithdrawAddressHomeState, _ store: Store<WithdrawAddressHomeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: WithdrawAddressHomeState,
        _ store: Store <WithdrawAddressHomeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
