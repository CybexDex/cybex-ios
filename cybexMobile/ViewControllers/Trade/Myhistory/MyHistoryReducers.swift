//
//  MyHistoryReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func myHistoryReducer(action: Action, state: MyHistoryState?) -> MyHistoryState {
    let state = state ?? MyHistoryState()

    switch action {
    case let action as FillOrderDataFetchedAction:
        state.fillOrders.accept(action.data)
    default:
        break
    }
    return state
}
