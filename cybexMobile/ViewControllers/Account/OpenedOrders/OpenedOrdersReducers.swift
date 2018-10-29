//
//  OpenedOrdersReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func gOpenedOrdersReducer(action: Action, state: OpenedOrdersState?) -> OpenedOrdersState {
    return OpenedOrdersState(isLoading: loadingReducer(state?.isLoading, action: action),
                             page: pageReducer(state?.page, action: action),
                             errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                             property: gOpenedOrdersPropertyReducer(state?.property, action: action))
}

func gOpenedOrdersPropertyReducer(_ state: OpenedOrdersPropertyState?, action: Action) -> OpenedOrdersPropertyState {
    let state = state ?? OpenedOrdersPropertyState()

    switch action {
    default:
        break
    }

    return state
}
