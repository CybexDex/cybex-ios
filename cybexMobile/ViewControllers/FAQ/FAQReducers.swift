//
//  FAQReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func FAQReducer(action: Action, state: FAQState?) -> FAQState {
    return FAQState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: FAQPropertyReducer(state?.property, action: action))
}

func FAQPropertyReducer(_ state: FAQPropertyState?, action: Action) -> FAQPropertyState {
    let state = state ?? FAQPropertyState()

    switch action {
    default:
        break
    }

    return state
}
