//
//  ETOCrowdReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ETOCrowdReducer(action:Action, state:ETOCrowdState?) -> ETOCrowdState {
    let state = state ?? ETOCrowdState()
        
    switch action {
    case let action as SetProjectDetailAction:
        state.data.accept(action.data)
    case let action as fetchCurrentTokenCountAction:
        state.userData.accept(action.userModel)
    case let action as SetFeeAction:
        state.fee.accept(action.fee)
    case let action as changeETOValidStatusAction:
        state.validStatus.accept(action.status)
    default:
        break
    }
        
    return state
}


