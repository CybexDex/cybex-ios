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
        state.data.accept(action.data)
    default:
        break
    }
    return state
}
