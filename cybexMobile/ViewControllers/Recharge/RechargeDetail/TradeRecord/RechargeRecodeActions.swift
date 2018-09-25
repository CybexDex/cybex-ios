//
//  RechargeRecodeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

//MARK: - State
struct RechargeRecodeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: RechargeRecodePropertyState
}

struct RechargeRecodePropertyState {
    var data : BehaviorRelay<TradeRecord?> = BehaviorRelay(value: nil)
    var asset : String = ""
}

struct FetchDepositRecordsAction : Action {
    var data : TradeRecord?
}

struct SetWithdrawListAssetAction : Action {
    var asset : String
}


//MARK: - Action Creator
class RechargeRecodePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: RechargeRecodeState, _ store: Store<RechargeRecodeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: RechargeRecodeState,
        _ store: Store <RechargeRecodeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
