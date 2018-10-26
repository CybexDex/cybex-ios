//
//  PickerReducers.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func PickerReducer(action: Action, state: PickerState?) -> PickerState {
    return PickerState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: PickerPropertyReducer(state?.property, action: action))
}

func PickerPropertyReducer(_ state: PickerPropertyState?, action: Action) -> PickerPropertyState {
    let state = state ?? PickerPropertyState()

    switch action {
    default:
        break
    }

    return state
}
