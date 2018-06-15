//
//  RechargeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func RechargeReducer(action:Action, state:RechargeState?) -> RechargeState {
    return RechargeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: RechargePropertyReducer(state?.property, action: action))
}

func RechargePropertyReducer(_ state: RechargePropertyState?, action: Action) -> RechargePropertyState {
    var state = state ?? RechargePropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



