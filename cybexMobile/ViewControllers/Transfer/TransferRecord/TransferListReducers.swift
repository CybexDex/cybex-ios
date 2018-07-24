//
//  TransferListReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TransferListReducer(action:Action, state:TransferListState?) -> TransferListState {
    return TransferListState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferListPropertyReducer(state?.property, action: action))
}

func TransferListPropertyReducer(_ state: TransferListPropertyState?, action: Action) -> TransferListPropertyState {
    var state = state ?? TransferListPropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



