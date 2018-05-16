//
//  LockupAssetsReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func LockupAssetsReducer(action:Action, state:LockupAssetsState?) -> LockupAssetsState {
    return LockupAssetsState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: LockupAssetsPropertyReducer(state?.property, action: action))
}

func LockupAssetsPropertyReducer(_ state: LockupAssetsPropertyState?, action: Action) -> LockupAssetsPropertyState {
    var state = state ?? LockupAssetsPropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



