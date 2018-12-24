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
    case let action as ChangeOrderBookOfPairAction:
        state.pair.accept(action.pair)
    case let action as FetchedOrderBookData:
        state.data.accept(action.data)
    case let action as ChangeDepthAndCountAction:
        state.depth.accept(action.depth)
        state.count = action.count
    case let action as FetchLastPriceAction:
        let oldPrice = state.lastPrice.value.0
        let color = state.lastPrice.value.1
        if oldPrice < action.price {
            state.lastPrice.accept((action.price, UIColor.turtleGreen))
        }
        else if oldPrice > action.price {
            state.lastPrice.accept((action.price, UIColor.reddish))
        }
        else {
            state.lastPrice.accept((action.price, color))
        }
    default:
        break
    }

    return state
}


