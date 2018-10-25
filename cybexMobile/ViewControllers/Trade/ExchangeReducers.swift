//
//  ExchangeReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ExchangeReducer(action: Action, state: ExchangeState?) -> ExchangeState {
    return ExchangeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: ExchangePropertyReducer(state?.property, action: action))
}

func ExchangePropertyReducer(_ state: ExchangePropertyState?, action: Action) -> ExchangePropertyState {
    var state = state ?? ExchangePropertyState()

    switch action {
    default:
        break
    }

    return state
}
