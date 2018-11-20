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

func gLockupAssetsReducer(action: Action, state: LockupAssetsState?) -> LockupAssetsState {
    let state = state ?? LockupAssetsState()
    switch action {
    case let action as FetchedLockupAssetsData:
        state.data.accept(lockupAssteToLockUpAssetsDate(datas: action.data))
    default:
        break
    }
    return state
}

func lockupAssteToLockUpAssetsDate(datas: [LockUpAssetsMData]) -> LockUpAssetsVMData {
    var sources = [LockupAssteData]()
//    let value = app_state.property.eth_rmb_price
    for data in datas {
        let quote  = data.balance.assetID
        let amount = data.balance.amount
        if let assetsInfo = appData.assetInfo[quote] {
//            let result = changeToETHAndCYB(quote)
            // 目前显示的是针对ETH的换算
            var count = "--"
            var price = "≈¥--"
            let name = assetsInfo.symbol

            count = getRealAmountDouble(quote, amount: amount).string(digits: assetsInfo.precision, roundingMode: .down)
            price = "≈¥" + (Decimal(getAssetRMBPrice(quote)) * getRealAmount(quote, amount: amount)).string(digits: 4, roundingMode: .down)

//            if result.eth != "",let amount_double = Double(amount) {
//                count = (amount_double / pow(10,Double(assetsInfo.precision))).string(digits: assetsInfo.precision)
//                if let count_double = Double(count) ,let resultEth = Double(result.eth) {
//                    price = "≈¥" + (count_double * resultEth * value).string(digits: 2)
//                }
//                name = assetsInfo.symbol
//            }
            let icon = AppConfiguration.ServerIconsBaseURLString + data.balance.assetID.replacingOccurrences(of: ".", with: "_") + "_grey.png"
            let vestingDurationSeconds = data.vestingPolicy.vestingDurationSeconds.toDouble() ?? 0
            if let beginTime = data.vestingPolicy.beginTimestamp.dateFromISO8601 {
                let progress = (Date().timeIntervalSince1970 - beginTime.timeIntervalSince1970) / vestingDurationSeconds
                let endTime = beginTime.addingTimeInterval(vestingDurationSeconds).string(withFormat: "yyyy/MM/dd")
                if progress < 1 && progress >= 0 {
                    sources.append(LockupAssteData(icon: icon, name: name, amount: count, RMBCount: price, progress: String(progress), endTime: endTime))
                }
            }
        } else {
            continue
        }
    }
    return LockUpAssetsVMData(datas: sources)
}
