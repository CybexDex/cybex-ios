//
//  Utils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

func calculateAssetRelation(assetID_A_name:String, assetID_B_name:String) -> (base:String, quote:String) {
  let relation:[String] = ["ETH", "BTC", "EOS", "CYB"]
  
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
  
  let homeBuckets : [HomeBucket] = app_data.data.value
  var result = (eth:"0",cyb:"0")
  for homeBuck : HomeBucket in homeBuckets {
    let bucket = BucketMatrix(homeBuck)
    if bucket.price == ""{
      continue
    }
    if homeBuck.base == eth_base && homeBuck.quote == sender {
      result.eth = bucket.price.replacingOccurrences(of: ",", with: "")
    }else if homeBuck.base == cyb_base && homeBuck.quote == sender {
      result.cyb = bucket.price.replacingOccurrences(of: ",", with: "")
    }
  }
  if (result.eth == "0" && result.cyb == "0") || (result.eth != "0" && result.cyb != "0") {
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
  let cyb_base   = AssetConfiguration.CYB
  let eth_quote = AssetConfiguration.ETH
  var result = "0"
  let homeBuckets : [HomeBucket] = app_data.data.value
  for homeBuck : HomeBucket in homeBuckets {
    if homeBuck.base == cyb_base && homeBuck.quote == eth_quote {
      let bucket = BucketMatrix(homeBuck)
      result = bucket.price.replacingOccurrences(of: ",", with: "")
      break
    }
  }
  if result == "0"{
    for homeBuck : HomeBucket in homeBuckets {
      if homeBuck.base == eth_quote && homeBuck.quote == cyb_base {
        let bucket = BucketMatrix(homeBuck)
        result = bucket.price.replacingOccurrences(of: ",", with: "")
        break
      }
    }
    if result != "0"{
      result = String(1 / result.toDouble()!)
    }
  }

  return result
}



func getRealAmount(_ id : String ,amount : String) -> Double{
  guard let asset = app_data.assetInfo[id] else {
    return 0
  }
  return amount.toDouble()! / pow(10, asset.precision.double)
  
}
