//
//  BusinessReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func BusinessReducer(action:Action, state:BusinessState?) -> BusinessState {
    return BusinessState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: BusinessPropertyReducer(state?.property, action: action))
}

func BusinessPropertyReducer(_ state: BusinessPropertyState?, action: Action) -> BusinessPropertyState {
    var state = state ?? BusinessPropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



