//
//  RechargeDetailReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func RechargeDetailReducer(action:Action, state:RechargeDetailState?) -> RechargeDetailState {
    return RechargeDetailState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: RechargeDetailPropertyReducer(state?.property, action: action))
}

func RechargeDetailPropertyReducer(_ state: RechargeDetailPropertyState?, action: Action) -> RechargeDetailPropertyState {
    var state = state ?? RechargeDetailPropertyState()
    
    switch action {
    case let action as FetchWithdrawInfo:
        state.data.accept(action.data)
    case let action as FetchWithdrawMemokey:
        state.memo_key.accept(action.data)
    case let action as FetchGatewayFee:
        state.gatewayFee.accept(action.data)
    case let action as SelectedAddressAction:
        state.withdrawAddress.accept(action.data)
    default:
        break
    }
    
    return state
}



