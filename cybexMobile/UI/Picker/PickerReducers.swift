//
//  PickerReducers.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func pickerReducer(action: Action, state: PickerState?) -> PickerState {
    return PickerState(isLoading: loadingReducer(state?.isLoading, action: action),
                       page: pageReducer(state?.page, action: action),
                       errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                       property: pickerPropertyReducer(state?.property, action: action))
}

func pickerPropertyReducer(_ state: PickerPropertyState?, action: Action) -> PickerPropertyState {
    let state = state ?? PickerPropertyState()

    switch action {
    default:
        break
    }

    return state
}
