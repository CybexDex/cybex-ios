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
        if state.pair.value != action.pair {
            state.data.accept(nil)
            break
        }
        state.data.accept(action.data)
    case let action as ChangeDepthAndCountAction:
        state.depth.accept(action.depth)
        state.count = action.count
    case let action as FetchLastPriceAction:
        if state.pair.value != action.pair {
            break
        }
        let oldPrice = state.lastPrice.value.0
        if oldPrice < action.price {
            state.lastPrice.accept((action.price, UIColor.turtleGreen))
        }
        else if oldPrice > action.price {
            state.lastPrice.accept((action.price, UIColor.reddish))
        }
        else {
            state.lastPrice.accept((action.price, UIColor.steel))
        }
    case let _ as ResetTickerAction:
        state.lastPrice.accept((0, UIColor.steel))
    default:
        break
    }

    return state
}


