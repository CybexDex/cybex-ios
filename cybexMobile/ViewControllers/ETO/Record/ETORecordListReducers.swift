//
//  ETORecordListReducers.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func ETORecordListReducer(action:Action, state:ETORecordListState?) -> ETORecordListState {
    let state = state ?? ETORecordListState()
        
    switch action {
    case let action as ETORecordListFetchedAction:
        if let model = [ETOTradeHistoryModel].deserialize(from: action.data["data"].arrayObject!)?.compactMap({ $0 }) {
            state.data.accept(model)
        }
    case let action as PageStateAction:
        state.pageState.accept(action.state)
    default:
        break
    }
        
    return state
}


