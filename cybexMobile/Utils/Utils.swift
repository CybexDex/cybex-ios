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
  
  
  if indexA < indexB {
    return (assetID_A_name, assetID_B_name)
  }
  else if indexA > indexB {
    return (assetID_B_name, assetID_A_name)
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


func getRealAmount(_ id : String ,amount : String) -> Double{
  guard let asset = app_data.assetInfo[id] else {
    return 0
  }
   return amount.toDouble()! / pow(10, asset.precision.toDouble)

}
