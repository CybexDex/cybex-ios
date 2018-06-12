//
//  RechargeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct RechargeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: RechargePropertyState
}

struct RechargePropertyState {
}

//MARK: - Action Creator
class RechargePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: RechargeState, _ store: Store<RechargeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: RechargeState,
        _ store: Store <RechargeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
