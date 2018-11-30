//
//  RechargeRecodeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func rechargeRecodeReducer(action: Action, state: RechargeRecodeState?) -> RechargeRecodeState {
    var state = state ?? RechargeRecodeState()

    switch action {
    case let action as FetchDepositRecordsAction:
        state.data.accept(action.data)
    case let action as SetWithdrawListAssetAction:
        state.asset = action.asset
    case let action as FetchAssetUrlAction:
        state.explorers.accept(action.data)
    default:
        break
    }
    return state
}
