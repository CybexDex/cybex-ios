//
//  TransferAddressHomeReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TransferAddressHomeReducer(action:Action, state:TransferAddressHomeState?) -> TransferAddressHomeState {
    return TransferAddressHomeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TransferAddressHomePropertyReducer(state?.property, action: action), callback:state?.callback ?? TransferAddressHomeCallbackState())
}

func TransferAddressHomePropertyReducer(_ state: TransferAddressHomePropertyState?, action: Action) -> TransferAddressHomePropertyState {
    let state = state ?? TransferAddressHomePropertyState()
    
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



