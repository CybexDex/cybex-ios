//
//  TradeHistoryReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func tradeHistoryReducer(action: Action, state: TradeHistoryState?) -> TradeHistoryState {
    let state = state ?? TradeHistoryState()

    switch action {
    case let action as FetchedFillOrderData:
        state.data.accept(action.data)
    default:
        break
    }

    return state
}
