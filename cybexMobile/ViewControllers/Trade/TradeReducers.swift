//
//  TradeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func TradeReducer(action:Action, state:TradeState?) -> TradeState {
    return TradeState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: TradePropertyReducer(state?.property, action: action))
}

func TradePropertyReducer(_ state: TradePropertyState?, action: Action) -> TradePropertyState {
    var state = state ?? TradePropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}




