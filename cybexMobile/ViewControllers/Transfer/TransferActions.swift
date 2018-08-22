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

enum AccountValidStatus: Int {
  case unValided = 0
  case validSuccessed
  case validFailed
  case validding
}

struct TransferPropertyState {  
  var accountValid: BehaviorRelay<AccountValidStatus> = BehaviorRelay(value: .unValided)
  
  var amountValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
  
  var balance: BehaviorRelay<Balance?> = BehaviorRelay(value: nil)
  
  var fee: BehaviorRelay<Fee?> = BehaviorRelay(value: nil)
  
  var account: BehaviorRelay<String> = BehaviorRelay(value: "")
  
  var amount: BehaviorRelay<String> = BehaviorRelay(value: "")
  
  var memo: BehaviorRelay<String> = BehaviorRelay(value: "")
  
  var to_account: BehaviorRelay<Account?> = BehaviorRelay(value: nil)
  
}

struct ValidAccountAction: Action {
  var status: AccountValidStatus = .unValided
}

struct ValidAmountAction: Action {
  var isValid: Bool = false
}

struct SetBalanceAction: Action {
  let balance: Balance
}

struct SetFeeAction: Action {
  let fee: Fee
}

struct SetToAccountAction: Action {
  let account: Account
}

struct ResetDataAction : Action {
  
}

struct ChooseAccountAction : Action {
    var account : TransferAddress
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
