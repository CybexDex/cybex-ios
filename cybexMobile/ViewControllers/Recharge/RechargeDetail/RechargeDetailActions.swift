//
//  RechargeDetailActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxSwift
import RxCocoa

//MARK: - State
struct RechargeDetailState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: RechargeDetailPropertyState
}

struct RechargeDetailPropertyState {
  var data : BehaviorRelay<WithdrawinfoObject?> = BehaviorRelay(value: nil)
  var memo_key : BehaviorRelay<String?> = BehaviorRelay(value: nil)
  var gatewayFee : BehaviorRelay<Fee?> = BehaviorRelay(value: nil)
}

struct FetchWithdrawInfo:Action {
  let data : WithdrawinfoObject
}

struct FetchWithdrawMemokey :Action {
  let data : String
}

struct FetchGatewayFee : Action{
  let data : Fee
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
