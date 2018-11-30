//
//  WithdrawAddressReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func withdrawAddressReducer(action: Action, state: WithdrawAddressState?) -> WithdrawAddressState {
    let state = state ?? WithdrawAddressState()

    switch action {
    case let action as WithdrawAddressDataAction:
        state.data.accept(action.data)
    case let action as WithdrawAddressSelectDataAction:
        state.selectedAddress.accept(action.data)
    case let action as SetSelectedAssetAction:
        state.selectedAsset.accept(action.asset)
    default:
        break
    }

    return state
}
