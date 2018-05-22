//
//  RegisterReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func RegisterReducer(action:Action, state:RegisterState?) -> RegisterState {
    return RegisterState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: RegisterPropertyReducer(state?.property, action: action))
}

func RegisterPropertyReducer(_ state: RegisterPropertyState?, action: Action) -> RegisterPropertyState {
    let state = state ?? RegisterPropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



