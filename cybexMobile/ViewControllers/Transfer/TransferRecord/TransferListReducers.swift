//
//  TransferListReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import HandyJSON

func TransferListReducer(action:Action, state:TransferListState?) -> TransferListState {
    return TransferListState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferListPropertyReducer(state?.property, action: action))
}

func TransferListPropertyReducer(_ state: TransferListPropertyState?, action: Action) -> TransferListPropertyState {
    var state = state ?? TransferListPropertyState()
    
    switch action {
    case let action as ReduceTansferRecordsAction :
      transferRecordsToViewModels(action.data) { (result) in
        state.data.accept(result)
      }
      break
    default:
        break
    }
    
    return state
}

func transferRecordsToViewModels(_ sender : [(TransferRecord,time:String)] ,callback:@escaping([TransferRecordViewModel])->()) {
  if sender.count == 0 {
    callback([])
  }
  
  if let account = UserManager.shared.account.value {
    var result : [TransferRecordViewModel] = [TransferRecordViewModel]()
    for source : (TransferRecord,time:String) in sender {
      let requeset_id = source.0.from == account.id ?  source.0.to : source.0.from
      let request = GetFullAccountsRequest(name: requeset_id) { (response) in
        if let data = response as? FullAccount, let account = data.account {
          let requeset_name = account.name
          let transferViewModel = TransferRecordViewModel(isSend: source.0.from == UserManager.shared.account.value?.id, from: source.0.from == account.id ? account.name : requeset_name, to: source.0.from == account.id ? requeset_name : account.name, time: source.time, amount: source.0.amount, memo: source.0.memo?.toJSONString() ?? "", vesting_period: source.0.vesting_period, fee: source.0.fee)
          result.append(transferViewModel)
          if result.count == sender.count {
            
            callback(result.filter({ (transferResult) -> Bool in
              if transferResult.isSend {
                return transferResult.to != "cybex-jadegateway"
              }
              else {
                return transferResult.from != "cybex-jadegateway"
              }
            }))
          }
        }
      }
      CybexWebSocketService.shared.send(request: request)
    }
  }
}



