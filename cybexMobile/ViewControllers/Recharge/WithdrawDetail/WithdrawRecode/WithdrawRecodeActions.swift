//
//  WithdrawRecodeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct WithdrawRecodeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: WithdrawRecodePropertyState
}

struct WithdrawRecodePropertyState {
}

//MARK: - Action Creator
class WithdrawRecodePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: WithdrawRecodeState, _ store: Store<WithdrawRecodeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: WithdrawRecodeState,
        _ store: Store <WithdrawRecodeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
