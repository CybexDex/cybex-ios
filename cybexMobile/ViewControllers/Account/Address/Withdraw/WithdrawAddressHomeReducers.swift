//
//  WithdrawAddressHomeReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func WithdrawAddressHomeReducer(action:Action, state:WithdrawAddressHomeState?) -> WithdrawAddressHomeState {
    return WithdrawAddressHomeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: WithdrawAddressHomePropertyReducer(state?.property, action: action), callback:state?.callback ?? WithdrawAddressHomeCallbackState())
}

func WithdrawAddressHomePropertyReducer(_ state: WithdrawAddressHomePropertyState?, action: Action) -> WithdrawAddressHomePropertyState {
    var state = state ?? WithdrawAddressHomePropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



