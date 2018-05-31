//
//  MarketReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func MarketReducer(action:Action, state:MarketState?) -> MarketState {
    return MarketState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: MarketPropertyReducer(state?.property, action: action))
}

func MarketPropertyReducer(_ state: MarketPropertyState?, action: Action) -> MarketPropertyState {
    let state = state ?? MarketPropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



