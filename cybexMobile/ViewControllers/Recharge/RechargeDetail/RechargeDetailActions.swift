//
//  RechargeDetailActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct RechargeDetailState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: RechargeDetailPropertyState
}

struct RechargeDetailPropertyState {
}

//MARK: - Action Creator
class RechargeDetailPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: RechargeDetailState, _ store: Store<RechargeDetailState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: RechargeDetailState,
        _ store: Store <RechargeDetailState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
