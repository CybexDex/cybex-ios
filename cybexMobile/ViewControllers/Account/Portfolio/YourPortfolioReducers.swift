//
//  YourPortfolioReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func YourPortfolioReducer(action: Action, state: YourPortfolioState?) -> YourPortfolioState {
    return YourPortfolioState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: YourPortfolioPropertyReducer(state?.property, action: action))
}

func YourPortfolioPropertyReducer(_ state: YourPortfolioPropertyState?, action: Action) -> YourPortfolioPropertyState {
    let state = state ?? YourPortfolioPropertyState()

    switch action {
    default:
        break
    }

    return state
}
