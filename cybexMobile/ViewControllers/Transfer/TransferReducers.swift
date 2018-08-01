//
//  TransferReducers.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TransferReducer(action:Action, state:TransferState?) -> TransferState {
  return TransferState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferPropertyReducer(state?.property, action: action))
}

func TransferPropertyReducer(_ state: TransferPropertyState?, action: Action) -> TransferPropertyState {
  let state = state ?? TransferPropertyState()
  
  switch action {
  case let action as ValidAccountAction:
    state.accountValid.accept(action.status)
  case let action as ValidAmountAction:
    state.amountValid.accept(action.isValid)
  case let action as SetBalanceAction:
    state.balance.accept(action.balance)
  case let action as SetFeeAction:
    state.fee.accept(action.fee)
  case let action as SetToAccountAction:
    state.to_account.accept(action.account)
  default:
    break
  }
  
  return state
}



