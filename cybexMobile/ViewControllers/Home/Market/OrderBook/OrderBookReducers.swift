//
//  OrderBookReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func orderBookReducer(action: ReSwift.Action, state: OrderBookState?) -> OrderBookState {
    var state = state ?? OrderBookState()
    switch action {
    case let action as ChangeOrderBookOfPairAction:
        state.pair.accept(action.pair)
    case let action as FetchedOrderBookData:
        if state.pair.value != action.pair {
            state.data.accept(nil)
            break
        }

        if var order = action.data {
            let precision = TradeConfiguration.shared.getPairPrecisionWithPair(action.pair)
            order.pricePrecision = state.depth.value
            order.amountPrecision = precision.book.amount.int!
            state.data.accept(order)
        }
        else {
            state.data.accept(nil)
        }
    case let action as ChangeDepthAndCountAction:
        state.depth.accept(action.depth)
        state.count = action.count
    case let action as FetchLastPriceAction:
        if state.pair.value != action.pair {
            break
        }
        let oldPrice = state.lastPrice.value.0
        if (oldPrice == 0) {
            state.lastPrice.accept((action.price, UIColor.steel))
        } else {
            if oldPrice < action.price {
                state.lastPrice.accept((action.price, UIColor.turtleGreen))
            }
            else if oldPrice > action.price {
                state.lastPrice.accept((action.price, UIColor.reddish))
            }
            else {
                if (state.lastPrice.value.1 != UIColor.turtleGreen && state.lastPrice.value.1 != UIColor.reddish) {
                    state.lastPrice.accept((action.price, UIColor.steel))
                }
            }
        }
        
    case _ as ResetTickerAction:
        state.lastPrice.accept((0, UIColor.steel))
    case let action as ChangeShowTypeIndexAction:
        state.showTypeIndex.accept(action.index)
    default:
        break
    }

    return state
}


