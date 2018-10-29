//
//  EntryReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func entryReducer(action: Action, state: EntryState?) -> EntryState {
    return EntryState(isLoading: loadingReducer(state?.isLoading, action: action),
                      page: pageReducer(state?.page, action: action),
                      errorMessage: errorMessageReducer(state?.errorMessage, action: action),
                      property: entryPropertyReducer(state?.property, action: action))
}

func entryPropertyReducer(_ state: EntryPropertyState?, action: Action) -> EntryPropertyState {
    let state = state ?? EntryPropertyState()

    switch action {
    default:
        break
    }

    return state
}
