//
//  TransferListReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TransferListReducer(action:Action, state:TransferListState?) -> TransferListState {
    return TransferListState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferListPropertyReducer(state?.property, action: action))
}

func TransferListPropertyReducer(_ state: TransferListPropertyState?, action: Action) -> TransferListPropertyState {
    var state = state ?? TransferListPropertyState()
    
    switch action {
    case let action as ReduceTansferRecordsAction :
      state.data.accept(transferRecordsToViewModels(action.data))
      break
    default:
        break
    }
    
    return state
}

func transferRecordsToViewModels(_ sender : [(TransferRecord,time:String)]) -> [TransferRecordViewModel]? {
  if sender.count == 0 {
    return nil
  }
  
  return sender.map({ (data) in
    TransferRecordViewModel(isSend: data.0.from == UserManager.shared.account.value?.id, from: data.0.from, to: data.0.to, time: data.time, amount: data.0.amount, memo: data.0.memo, vesting_period: data.0.vesting_period, fee: data.0.fee)
  })
  
}



