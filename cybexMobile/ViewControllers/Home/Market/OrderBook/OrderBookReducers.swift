//
//  OrderBookReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func orderBookReducer(action: Action, state: OrderBookState?) -> OrderBookState {
    var state = state ?? OrderBookState()

    switch action {
    case let action as FetchedOrderBookData:
        state.pair.accept(action.pair)
        state.data.accept(action.data)
    case let action as ChangeDepthAndCountAction:
        state.depth.accept(action.depth)
        state.count = action.count
    default:
        break
    }

    return state
}


