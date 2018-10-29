//
//  SettingReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func gSettingReducer(action: Action, state: SettingState?) -> SettingState {
    return SettingState(isLoading: loadingReducer(state?.isLoading, action: action),
                        page: pageReducer(state?.page, action: action),
                        errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                        property: gSettingPropertyReducer(state?.property, action: action))
}

func gSettingPropertyReducer(_ state: SettingPropertyState?, action: Action) -> SettingPropertyState {
    let state = state ?? SettingPropertyState()

    switch action {
    default:
        break
    }

    return state
}
