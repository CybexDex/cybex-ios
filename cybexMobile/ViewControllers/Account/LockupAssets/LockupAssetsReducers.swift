//
//  LockupAssetsReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftTheme


func LockupAssetsReducer(action:Action, state:LockupAssetsState?) -> LockupAssetsState {
    return LockupAssetsState(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: LockupAssetsPropertyReducer(state?.property, action: action))
}

func LockupAssetsPropertyReducer(_ state: LockupAssetsPropertyState?, action: Action) -> LockupAssetsPropertyState {
    let state = state ?? LockupAssetsPropertyState()
    switch action {
    case let action as FetchedLockupAssetsData:
        state.data.accept(lockupAssteToLockUpAssetsDate(datas: action.data))
    default:
        break
    }
    return state
}


func lockupAssteToLockUpAssetsDate(datas : [LockUpAssetsMData]) -> LockUpAssetsVMData{
    var sources = [LockupAssteData]()
//    let value = app_state.property.eth_rmb_price
    for data in datas{
        let quote  = data.balance.assetID
        let amount = data.balance.amount
        if let assetsInfo = app_data.assetInfo[quote] {
//            let result = changeToETHAndCYB(quote)
            // 目前显示的是针对ETH的换算
            var count = "--"
            var price = "≈¥--"
            let name = assetsInfo.symbol
            
            count = getRealAmountDouble(quote, amount: amount).string(digits: assetsInfo.precision, roundingMode: .down)
            price = "≈¥" + (Decimal(getAssetRMBPrice(quote)) * getRealAmount(quote, amount: amount)).string(digits: 2, roundingMode: .down)
            
//            if result.eth != "",let amount_double = Double(amount) {
//                count = (amount_double / pow(10,Double(assetsInfo.precision))).string(digits: assetsInfo.precision)
//                if let count_double = Double(count) ,let resultEth = Double(result.eth) {
//                    price = "≈¥" + (count_double * resultEth * value).string(digits: 2)
//                }
//                name = assetsInfo.symbol
//            }
            let icon = AppConfiguration.SERVER_ICONS_BASE_URLString + data.balance.assetID.replacingOccurrences(of: ".", with: "_") + "_grey.png"
            let vesting_duration_seconds = data.vesting_policy.vesting_duration_seconds.toDouble() ?? 0
            if let begin_time = data.vesting_policy.begin_timestamp.dateFromISO8601 {
                let progress = (Date().timeIntervalSince1970 - begin_time.timeIntervalSince1970) / vesting_duration_seconds
                let end_time = begin_time.addingTimeInterval(vesting_duration_seconds).string(withFormat: "yyyy/MM/dd")
                if progress < 1 && progress >= 0 {
                    sources.append(LockupAssteData(icon: icon, name: name, amount: count, RMBCount: price, progress: String(progress), endTime: end_time))
                }
            }
        }
        else {
            continue
        }
    }
    return LockUpAssetsVMData(datas: sources)
}




