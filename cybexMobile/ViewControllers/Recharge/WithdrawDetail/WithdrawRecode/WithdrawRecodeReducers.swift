//
//  WithdrawRecodeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func WithdrawRecodeReducer(action:Action, state:WithdrawRecodeState?) -> WithdrawRecodeState {
    return WithdrawRecodeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: WithdrawRecodePropertyReducer(state?.property, action: action))
}

func WithdrawRecodePropertyReducer(_ state: WithdrawRecodePropertyState?, action: Action) -> WithdrawRecodePropertyState {
    var state = state ?? WithdrawRecodePropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



