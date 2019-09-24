//
//  AddAddressReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func addAddressReducer(action: ReSwift.Action, state: AddAddressState?) -> AddAddressState {
    let state = state ?? AddAddressState()

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
