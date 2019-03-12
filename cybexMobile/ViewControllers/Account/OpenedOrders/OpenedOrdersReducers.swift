//
//  OpenedOrdersReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func gOpenedOrdersReducer(action: Action, state: OpenedOrdersState?) -> OpenedOrdersState {
    let state = state ?? OpenedOrdersState()
    switch action {
    case let action as FetchOpenedOrderAction:
        let data = action.all ? action.data.filter { (order) -> Bool in
            return MarketConfiguration.shared.marketPairs.value.contains(order.getPair())
            } : action.data
        state.data.accept(data)
    default:
        break
    }
    return state
}
