//
//  RechargeDetailReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func rechargeDetailReducer(action: Action, state: RechargeDetailState?) -> RechargeDetailState {
    let state = state ?? RechargeDetailState()

    switch action {
    case let action as FetchWithdrawInfo:
        state.data.accept(action.data)
    case let action as FetchWithdrawMemokey:
        state.memoKey.accept(action.data)
    case let action as FetchGatewayFee:
        state.gatewayFee.accept(action.data)
    case let action as SelectedAddressAction:
        state.withdrawAddress.accept(action.data)
    default:
        break
    }

    return state
}
