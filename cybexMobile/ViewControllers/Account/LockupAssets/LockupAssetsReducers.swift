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
  let value   = app_state.property.eth_rmb_price
  for data in datas{
    let quote  = data.balance.assetID
    let amount = data.balance.amount
    let result = changeToETHAndCYB(quote)
    // 目前显示的是针对ETH的换算
    let assetsInfo =  app_data.assetInfo[quote]
    var count = "--"
    var price = "≈¥--"
    if result.eth != ""{
      
      count = String(Double(amount)! / pow(10,Double((assetsInfo?.precision)!))).formatCurrency(digitNum: app_data.assetInfo[quote]!.precision)
      price = "≈¥" + String(Double(count)!*Double(result.eth)! * value).formatCurrency(digitNum: 2)
    }
    let name  =  assetsInfo?.symbol
    let icon = AppConfiguration.SERVER_ICONS_BASE_URLString + data.balance.assetID.replacingOccurrences(of: ".", with: "_") + "_grey.png"
    let vesting_duration_seconds = data.vesting_policy.vesting_duration_seconds.toDouble()!
    let begin_time               = data.vesting_policy.begin_timestamp.dateFromISO8601
    let progress = (Date().timeIntervalSince1970 - (begin_time?.timeIntervalSince1970)!) / vesting_duration_seconds
    let end_time = begin_time?.addingTimeInterval(vesting_duration_seconds).string(withFormat: "yyyy/MM/dd")
    if progress < 1 && progress >= 0 {
      sources.append(LockupAssteData(icon: icon, name: name!, amount: count, RMBCount: price, progress: String(progress), endTime: end_time!))
    }
  }
  return LockUpAssetsVMData(datas: sources)
}




