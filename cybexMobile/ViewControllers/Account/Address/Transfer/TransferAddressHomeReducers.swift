//
//  TransferAddressHomeReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func transferAddressHomeReducer(action: ReSwift.Action, state: TransferAddressHomeState?) -> TransferAddressHomeState {
    let state = state ?? TransferAddressHomeState()

    switch action {
    case let action as TransferAddressHomeDataAction:
        state.data.accept(action.data)
    case let action as TransferAddressSelectDataAction:
        state.selectedAddress.accept(action.data)
    default:
        break
    }

    return state
}
