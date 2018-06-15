//
//  ChooseReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ChooseReducer(action:Action, state:ChooseState?) -> ChooseState {
    return ChooseState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: ChoosePropertyReducer(state?.property, action: action))
}

func ChoosePropertyReducer(_ state: ChoosePropertyState?, action: Action) -> ChoosePropertyState {
    var state = state ?? ChoosePropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



