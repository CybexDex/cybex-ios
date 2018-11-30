//
//  WithdrawDetailReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func withdrawDetailReducer(action: Action, state: WithdrawDetailState?) -> WithdrawDetailState {
    let state = state ?? WithdrawDetailState()

    switch action {
    case let action as FetchAddressInfo:
        state.data.accept(action.data)
    default:
        break
    }

    return state
}
