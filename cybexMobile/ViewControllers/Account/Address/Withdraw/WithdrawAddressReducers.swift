//
//  WithdrawAddressReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func WithdrawAddressReducer(action:Action, state:WithdrawAddressState?) -> WithdrawAddressState {
    return WithdrawAddressState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: WithdrawAddressPropertyReducer(state?.property, action: action), callback:state?.callback ?? WithdrawAddressCallbackState())
}

func WithdrawAddressPropertyReducer(_ state: WithdrawAddressPropertyState?, action: Action) -> WithdrawAddressPropertyState {
    let state = state ?? WithdrawAddressPropertyState()
    
    switch action {
    case let action as WithdrawAddressDataAction:
        state.data.accept(action.data)
    case let action as WithdrawAddressSelectDataAction:
        state.selectedAddress.accept(action.data)
    default:
        break
    }
    
    return state
}



