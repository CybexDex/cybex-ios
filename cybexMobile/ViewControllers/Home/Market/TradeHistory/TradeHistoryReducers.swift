//
//  TradeHistoryReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TradeHistoryReducer(action:Action, state:TradeHistoryState?) -> TradeHistoryState {
    return TradeHistoryState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TradeHistoryPropertyReducer(state?.property, action: action))
}

func TradeHistoryPropertyReducer(_ state: TradeHistoryPropertyState?, action: Action) -> TradeHistoryPropertyState {
    var state = state ?? TradeHistoryPropertyState()
    
    switch action {
    case let action as FetchedFillOrderData:
      state.data.accept(action.data)
    default:
        break
    }
    
    return state
}



