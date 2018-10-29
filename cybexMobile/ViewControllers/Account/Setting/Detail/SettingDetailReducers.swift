//
//  SettingDetailReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/2.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func gSettingDetailReducer(action: Action, state: SettingDetailState?) -> SettingDetailState {
    return SettingDetailState(isLoading: loadingReducer(state?.isLoading, action: action),
                              page: pageReducer(state?.page, action: action),
                              errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                              property: gSettingDetailPropertyReducer(state?.property, action: action))
}

func gSettingDetailPropertyReducer(_ state: SettingDetailPropertyState?, action: Action) -> SettingDetailPropertyState {
    let state = state ?? SettingDetailPropertyState()

    switch action {
    default:
        break
    }

    return state
}
