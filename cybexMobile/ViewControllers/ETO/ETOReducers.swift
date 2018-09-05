//
//  ETOReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ETOReducer(action:Action, state:ETOState?) -> ETOState {
    let state = state ?? ETOState()
    switch action {
        case let action as FetchProjectModelAction:
            state.data.accept(action.data)
            break
        default:break
    }
    return state
}

func transferModelToViewModel(_ data : [ETOProjectModel]) {

   
}
