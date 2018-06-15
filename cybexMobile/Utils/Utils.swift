//
//  Utils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

func calculateAssetRelation(assetID_A_name:String, assetID_B_name:String) -> (base:String, quote:String) {
  let relation:[String] = AssetConfiguration.order_name

  
  var indexA = -1
  var indexB = -1
  
  if let index = relation.index(of: assetID_A_name) {
    indexA = index
  }
  
  if let index = relation.index(of: assetID_B_name) {
    indexB = index
  }
  
  
  if indexA > -1 && indexB > -1 {
    if indexA < indexB {
      return (assetID_A_name, assetID_B_name)
    }
    else {
      return (assetID_B_name, assetID_A_name)
    }
  }
  else if indexA < indexB {
    return (assetID_B_name, assetID_A_name)
  }
  else if indexA > indexB {
    return (assetID_A_name, assetID_B_name)
  }
  else {
    if assetID_A_name < assetID_B_name {
      return (assetID_A_name, assetID_B_name)
    }
    else {
      return (assetID_B_name, assetID_A_name)
    }
  }
  
}



//********************深度优化************************
// MARK : 传入quote 导出多少个ETH。多少个CYB
/**
 规则:
 1 如果返回的都非0/都为0，则直接返回
 2 先判断CYB/ETH 或者ETH/CYB 是否有值，如果其中一个有值就转换，反之没有数据的币对返回0
 **/
func changeToETHAndCYB(_ sender : String) -> (eth:String,cyb:String){
  let eth_base = AssetConfiguration.ETH
  let cyb_base = AssetConfiguration.CYB
  let eth_cyb  = changeCYB_ETH()
  if sender == eth_base {
    return ("1",eth_cyb)
  }else if (sender == cyb_base){
    if let eth_cyb_double = Double(eth_cyb), eth_cyb_double != 0 {
      return (String(1.0/Double(eth_cyb)!),"1")
    }
  }
  
  var result = (eth:"0",cyb:"0")
  let homeBuckets : [HomeBucket] = app_data.data.value
  for homeBuck : HomeBucket in homeBuckets {
    let bucket = getCachedBucket(homeBuck)
    
    if homeBuck.base == eth_base && homeBuck.quote == sender {
      if bucket.price == ""{
        continue
      }
      result.eth = bucket.price.replacingOccurrences(of: ",", with: "")
    }else if homeBuck.base == cyb_base && homeBuck.quote == sender {
      if bucket.price == ""{
        continue
      }
      result.cyb = bucket.price.replacingOccurrences(of: ",", with: "")
    }
  }
  
  if (result.eth == "0" && result.cyb == "0") {
    var sender_rmb_price = "0"
    var eth_rmb_price = "0"
    var cyb_rmb_price = "0"
    for price in app_data.rmb_prices{
      if app_data.assetInfo[sender]?.symbol.filterJade == price.name{
        sender_rmb_price = price.rmb_price
      }else if "CYB" == price.name{
        cyb_rmb_price = price.rmb_price
      }else if "ETH" == price.name{
        eth_rmb_price = price.rmb_price
      }
    }
    if sender_rmb_price == "0"{
      return result
    }
    if eth_rmb_price != "0" {
      result.eth = String(sender_rmb_price.toDouble()! / eth_rmb_price.toDouble()!)
      result.cyb = String (eth_cyb.toDouble()! * result.eth.toDouble()!)
    }else if cyb_rmb_price != "0"{
      result.cyb = String(sender_rmb_price.toDouble()! / cyb_rmb_price.toDouble()!)
      result.eth = String (eth_cyb.toDouble()! * 1 / result.cyb.toDouble()!)
    }
    return result
    
  }else if (result.eth != "0" && result.cyb != "0"){
    return result
  }else {
    if eth_cyb != "0" {
      if(result.eth == "0"){
        result.eth = String(Double(result.cyb)! * Double(1 / Double(eth_cyb)!))
      }else if(result.cyb == "0"){
        result.cyb = String(Double(result.eth)! * Double(changeCYB_ETH())!)
      }
      return result
    }
    return result
  }
}



// 获取CYB和ETH的转换关系
/**
 如果CYB作为base  ETH作为quote。没有值，则ETH作为quote  CYB作为base，如果都没有值返回0
 **/
// CYB:base  ETH:quote
func changeCYB_ETH() -> String{
  //  return "0"
  let cyb_base   = AssetConfiguration.CYB
  let eth_quote  = AssetConfiguration.ETH
  var result     = getRelationWithIds(base: cyb_base, quote: eth_quote)
  if result != "0"{
    return result
  }
  let homeBuckets : [HomeBucket] = app_data.data.value
  for homeBuck : HomeBucket in homeBuckets {
    if homeBuck.base == cyb_base && homeBuck.quote == eth_quote {
      
      let bucket = getCachedBucket(homeBuck)
      result = bucket.price.replacingOccurrences(of: ",", with: "")
      break
    }
  }
  if result == "0"{
    for homeBuck : HomeBucket in homeBuckets {
      if homeBuck.base == eth_quote && homeBuck.quote == cyb_base {
        let bucket = getCachedBucket(homeBuck)
        result = bucket.price.replacingOccurrences(of: ",", with: "")
        break
      }
    }
    if result != "0"{
      if result == "" {
        return "0"
      }
      result = String(1 / result.toDouble()!)
    }
  }
  
  return result
}

// 根据base 和quote对比的RMB 然后转换
func getRelationWithIds(base:String,quote:String) -> String{
  let rmb_prices = AppConfiguration.shared.appCoordinator.state.property.rmb_prices
  let base_name  = app_data.assetInfo[base]?.symbol.filterJade ?? "--"
  let quote_name = app_data.assetInfo[quote]?.symbol.filterJade ?? "--"
  var base_rmb = "0"
  var quote_rmb = "0"
  for price in rmb_prices {
    if price.name == base_name{
      base_rmb = price.rmb_price
    }else if price.name == quote_name{
      quote_rmb = price.rmb_price
    }
  }
  
  if base_rmb != "0" && quote_rmb != "0" {
    return String(quote_rmb.toDouble()! / base_rmb.toDouble()!)
  }
  return "0"
}






func getCachedBucket(_ homebucket:HomeBucket) -> BucketMatrix {
  var result:BucketMatrix?
  var matrixs = app_state.property.matrixs.value
  
  if let bucket = matrixs[Pair(base:homebucket.base, quote:homebucket.quote)] {
    result = bucket
  }
  
  return result ?? BucketMatrix(homebucket)
  
}


func getRealAmount(_ id : String ,amount : String) -> Double{
  guard let asset = app_data.assetInfo[id] else {
    return 0
  }
  return amount.toDouble()! / pow(10, asset.precision.double)
  
}
