//
//  MyHistoryReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func myHistoryReducer(action: Action, state: MyHistoryState?) -> MyHistoryState {
    return MyHistoryState(isLoading: loadingReducer(state?.isLoading, action: action),
                          page: pageReducer(state?.page, action: action),
                          errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                          property: myHistoryPropertyReducer(state?.property, action: action))
}

func myHistoryPropertyReducer(_ state: MyHistoryPropertyState?, action: Action) -> MyHistoryPropertyState {
    let state = state ?? MyHistoryPropertyState()
    switch action {
    default:
        break
    }

    return state
}
