//
//  TransferDetailReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TransferDetailReducer(action: Action, state: TransferDetailState?) -> TransferDetailState {
    return TransferDetailState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferDetailPropertyReducer(state?.property, action: action))
}

func TransferDetailPropertyReducer(_ state: TransferDetailPropertyState?, action: Action) -> TransferDetailPropertyState {
    let state = state ?? TransferDetailPropertyState()

    switch action {
    default:
        break
    }

    return state
}
