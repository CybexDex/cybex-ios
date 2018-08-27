//
//  RechargeRecodeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func RechargeRecodeReducer(action:Action, state:RechargeRecodeState?) -> RechargeRecodeState {
    return RechargeRecodeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: RechargeRecodePropertyReducer(state?.property, action: action))
}

func RechargeRecodePropertyReducer(_ state: RechargeRecodePropertyState?, action: Action) -> RechargeRecodePropertyState {
    var state = state ?? RechargeRecodePropertyState()
    
    switch action {
    case let action as FetchDepositRecordsAction:
        
        state.data.accept(transferDepositRecords(action.data,asset_id : action.asset_id))
    case let action as SetWithdrawListAssetAction:
        state.asset = action.asset
    default:
        break
    }
    return state
}

func transferDepositRecords(_ sender : TradeRecord? , asset_id : String) -> TradeRecord? {
    guard var tradeRecord = sender else { return nil }
    if var records = tradeRecord.records {
        for index in 0..<records.count {
            var record = records[index]
            record.asset_id = asset_id
            records.remove(at: index)
            records.insert(record, at: index)
        }
        tradeRecord.records = records
    }
    
    return tradeRecord
}



