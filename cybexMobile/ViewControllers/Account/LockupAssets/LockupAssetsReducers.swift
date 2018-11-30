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
    for data in datas {
        let quote  = data.balance.assetID
        let amount = data.balance.amount
        if let assetsInfo = appData.assetInfo[quote] {
            var count = "--"
            var price = "≈¥--"
            let name = assetsInfo.symbol

            count = getRealAmountDouble(quote, amount: amount).string(digits: assetsInfo.precision, roundingMode: .down)
            price = "≈¥" + (Decimal(getAssetRMBPrice(quote)) * getRealAmount(quote, amount: amount)).string(digits: 4, roundingMode: .down)
            
            let icon = AppConfiguration.ServerIconsBaseURLString + data.balance.assetID.replacingOccurrences(of: ".", with: "_") + "_grey.png"
            let vestingDurationSeconds = data.vestingPolicy.vestingDurationSeconds.toDouble() ?? 0
            if let beginTime = data.vestingPolicy.beginTimestamp.dateFromISO8601 {
                var progress = (Date().timeIntervalSince1970 - beginTime.timeIntervalSince1970) / vestingDurationSeconds
                if progress > 1 {
                    progress = 1
                }
                let endTime = beginTime.addingTimeInterval(vestingDurationSeconds).string(withFormat: "yyyy/MM/dd")
                if progress >= 0 {
                    sources.append(LockupAssteData(icon: icon,
                                                   name: name,
                                                   amount: count,
                                                   RMBCount: price,
                                                   progress: String(progress),
                                                   endTime: endTime,
                                                   id: data.id,
                                                   balance: data.balance,
                                                   owner: data.owner))
                }
            }
        } else {
            continue
        }
    }
    return LockUpAssetsVMData(datas: sources)
}
