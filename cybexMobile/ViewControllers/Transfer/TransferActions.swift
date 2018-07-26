//
//  TransferActions.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

//MARK: - State
struct TransferState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: TransferPropertyState
}

struct TransferPropertyState {
  var data : BehaviorRelay<WithdrawinfoObject?> = BehaviorRelay(value: nil)
  
  var accountValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
  
  var amountValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
  
  var balance: BehaviorRelay<Balance?> = BehaviorRelay(value: nil)
  
  var fee: BehaviorRelay<String> = BehaviorRelay(value: "--CYB")
  
  var amount: BehaviorRelay<String> = BehaviorRelay(value: "")
  
  var memo: BehaviorRelay<String> = BehaviorRelay(value: "")
  
}

struct ValidAccountAction: Action {
  var isValid: Bool = false
}

struct ValidAmountAction: Action {
  var isValid: Bool = false
}

struct SetBalanceAction: Action {
  let balance: Balance
}

struct SetFeeAction: Action {
  var fee: String = "0"
}

//MARK: - Action Creator
class TransferPropertyActionCreate {
    public typealias ActionCreator = (_ state: TransferState, _ store: Store<TransferState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: TransferState,
        _ store: Store <TransferState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
