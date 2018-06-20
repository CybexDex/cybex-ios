//
//  WithdrawDetailReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func WithdrawDetailReducer(action:Action, state:WithdrawDetailState?) -> WithdrawDetailState {
    return WithdrawDetailState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: WithdrawDetailPropertyReducer(state?.property, action: action))
}

func WithdrawDetailPropertyReducer(_ state: WithdrawDetailPropertyState?, action: Action) -> WithdrawDetailPropertyState {
    var state = state ?? WithdrawDetailPropertyState()
    switch action {
    case let action as FetchAddressInfo:
      state.data.accept(action.data)
    default:
        break
    }
    
    return state
}



