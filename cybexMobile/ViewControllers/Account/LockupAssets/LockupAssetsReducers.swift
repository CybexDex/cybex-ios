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
import EZSwiftExtensions

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
  for data in datas{
    let quote = data.balance.assetID
    let amount = data.balance.amount
    let result = changeToETHAndCYB(quote)
    // 目前显示的是针对ETH的换算
    let assetsInfo =  app_data.assetInfo[quote]
    var count = "--"
    var price = "≈¥--"
    if result.eth != ""{
      count = String(Double(amount)! / pow(10,Double((assetsInfo?.precision)!)))
      price = "≈¥" + String(Double(count)!*Double(result.eth)!)
    }
    let name  =  assetsInfo?.symbol
    let icon  = ThemeManager.currentThemeIndex == 0 ? "icBtc" : "icBtcGrey"
    let vesting_duration_seconds = data.vesting_policy.vesting_duration_seconds.toDouble()!
    let begin_time               = data.vesting_policy.begin_timestamp.dateFromISO8601
    let progress = (Date().timeIntervalSince1970 - (begin_time?.timeIntervalSince1970)!) / vesting_duration_seconds
    let end_time = begin_time?.addingTimeInterval(vesting_duration_seconds).toString(format: "yyyy/MM/dd")
    sources.append(LockupAssteData(icon: icon, name: name!, amount: count, RMBCount: price, progress: String(progress), endTime: end_time!))
  }
  return LockUpAssetsVMData(datas: sources)
}



// MARK : 传入quote 导出多少个ETH。多少个CYB
func changeToETHAndCYB(_ sender : String) -> (eth:String,cyb:String){
  let eth_base = "1.3.2"
  let cyb_base = "1.3.0"
  let eth_cyb = changeCYB_ETH()
  
  if sender == eth_base {
    return ("1",eth_cyb)
  }else if (sender == cyb_base){
    return (String(1.0/Double(eth_cyb)!),"1")
  }
  let homeBuckets : [HomeBucket] = app_data.data.value
  var result = (eth:"",cyb:"")
  for homeBuck : HomeBucket in homeBuckets {
    if homeBuck.base == eth_base && homeBuck.quote == sender {
      let bucket = BucketMatrix(homeBuck)
      result.eth = bucket.price.replacingOccurrences(of: ",", with: "")
    }else if homeBuck.base == cyb_base && homeBuck.quote == sender {
      let bucket = BucketMatrix(homeBuck)
      result.cyb = bucket.price.replacingOccurrences(of: ",", with: "")
    }
  }
  
  /// 这是在 方法changeCYB_ETH绝对有值的情况下才能使用
  //  如果没有值 就要显示为空
  let cyb_eth = changeCYB_ETH()
  
  if  cyb_eth != "" {
    if result.eth == "" && result.cyb == "" {
    }else if(result.eth == ""){
      result.eth = String(Double(result.cyb)! * Double(1 / Double(cyb_eth)!))
    }else if(result.cyb == ""){
      result.cyb = String(Double(result.eth)! * Double(changeCYB_ETH())!)
    }
  }
  return (result)
}

// CYB:base  ETH:quote
func changeCYB_ETH() -> String{
  let cyb_base   = "1.3.0"
  let eth_quote = "1.3.2"
  var result = ""
  let homeBuckets : [HomeBucket] = app_data.data.value
  for homeBuck : HomeBucket in homeBuckets {
    if homeBuck.base == cyb_base && homeBuck.quote == eth_quote {
      let bucket = BucketMatrix(homeBuck)
      result = bucket.price.replacingOccurrences(of: ",", with: "")
      break
    }
  }
  return result
}
