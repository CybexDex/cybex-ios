//
//  RechargeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import RxSwift

//MARK: - State
struct RechargeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: RechargePropertyState
}

struct RechargePropertyState {
  var withdrawIds : BehaviorRelay<[Trade]> = BehaviorRelay(value:[])
  var depositIds : BehaviorRelay<[Trade]> = BehaviorRelay(value: [])
}
struct FecthWithdrawIds : Action {
  let data : [Trade]
}

struct FecthDepositIds : Action{
  let data : [Trade]
}
struct Trade{
  var id : String = ""
  var enable : Bool = true
  var message : String = ""
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
