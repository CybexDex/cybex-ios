//
//  MyHistoryReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func myHistoryReducer(action: ReSwift.Action, state: MyHistoryState?) -> MyHistoryState {
    let state = state ?? MyHistoryState()

    switch action {
    case let action as FillOrderDataFetchedAction:
        let data = action.data
        state.fillOrders.accept(data)
    default:
        break
    }
    return state
}
