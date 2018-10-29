//
//  RechargeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func rechargeReducer(action: Action, state: RechargeState?) -> RechargeState {
    let state = state ?? RechargeState()

    switch action {
    case let action as FecthDepositIds:state.depositIds.accept(action.data)
    case let action as FecthWithdrawIds:state.withdrawIds.accept(action.data)
    default:
        break
    }

    return state
}
