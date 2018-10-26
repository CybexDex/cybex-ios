//
//  AddAddressReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func AddAddressReducer(action: Action, state: AddAddressState?) -> AddAddressState {
    return AddAddressState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: AddAddressPropertyReducer(state?.property, action: action))
}

func AddAddressPropertyReducer(_ state: AddAddressPropertyState?, action: Action) -> AddAddressPropertyState {
    let state = state ?? AddAddressPropertyState()

    switch action {
    case let action as SetAssetAction:
        state.asset.accept(action.data)

    case let action as VerificationAddressAction :
        state.addressVailed.accept(action.success)
    case let action as VerificationNoteAction:
        state.noteVailed.accept(action.data)
    case let action as SetNoteAction:
        state.note.accept(action.data)
    case let action as SetAddressAction:
        state.address.accept(action.data)

    default:
        break
    }

    return state
}
