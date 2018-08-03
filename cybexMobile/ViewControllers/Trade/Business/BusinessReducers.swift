//
//  BusinessReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func BusinessReducer(action:Action, state:BusinessState?) -> BusinessState {
    return BusinessState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: BusinessPropertyReducer(state?.property, action: action))
}

func BusinessPropertyReducer(_ state: BusinessPropertyState?, action: Action) -> BusinessPropertyState {
    var state = state ?? BusinessPropertyState()
    
    switch action {
    case let action as changePriceAction:
      state.price.accept(action.price)
    case let action as adjustPriceAction:
      let precision = state.price.value.tradePrice.pricision
      let gap = action.plus ? 1.0 / pow(10, precision.double) : -1.0 / pow(10, precision.double)
      
      if let price = state.price.value.toDouble(), price != 0, price + gap > 0 {
        state.price.accept((price + gap).tradePrice().price)
      }
    case let action as feeFetchedAction:
      state.fee_amount.accept(action.amount)
      state.feeID.accept(action.assetID)
    case let action as BalanceFetchedAction:
      state.balance.accept(action.amount)
    case let action as switchPercentAction:
      state.amount.accept(action.amount.string(digits: 10 - state.price.value.tradePrice.pricision,roundingMode:.down))
    case _ as resetTrade:
      state.price.accept("")
      state.fee_amount.accept(0)
      state.balance.accept(0)
      state.feeID.accept("")
      state.amount.accept("")
    default:
        break
    }
    
    return state
}



