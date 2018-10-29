//
//  AccountReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func gAccountReducer(action: Action, state: AccountState?) -> AccountState {
    return AccountState(isLoading: loadingReducer(state?.isLoading, action: action),
                        page: pageReducer(state?.page, action: action),
                        errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                        property: gAccountPropertyReducer(state?.property, action: action))
}

func gAccountPropertyReducer(_ state: AccountPropertyState?, action: Action) -> AccountPropertyState {
    let state = state ?? AccountPropertyState()

    switch action {

    default:
        break
    }

    return state
}
