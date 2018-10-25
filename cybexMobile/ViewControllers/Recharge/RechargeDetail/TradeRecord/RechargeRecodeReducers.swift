//
//  RechargeRecodeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func RechargeRecodeReducer(action: Action, state: RechargeRecodeState?) -> RechargeRecodeState {
    return RechargeRecodeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: RechargeRecodePropertyReducer(state?.property, action: action))
}

func RechargeRecodePropertyReducer(_ state: RechargeRecodePropertyState?, action: Action) -> RechargeRecodePropertyState {
    var state = state ?? RechargeRecodePropertyState()

    switch action {
    case let action as FetchDepositRecordsAction:
        state.data.accept(action.data)
    case let action as SetWithdrawListAssetAction:
        state.asset = action.asset
    case let action as FetchAssetUrlAction:
        state.explorers.accept(action.data)
    default:
        break
    }
    return state
}
