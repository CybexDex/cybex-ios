//
//  Utils.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift

func calculateFee(_ operation:String, focus_asset_id:String, operationID:ChainTypesOperations = .limit_order_create, completion:@escaping (_ success:Bool, _ amount:Double, _ assetID:String)->()) {
  let request = GetRequiredFees(response: { (data) in
    if let fees = data as? [Fee], let cyb_amount = fees.first?.amount.toDouble() {
      
      if let cyb = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
        return balance.asset_type == AssetConfiguration.CYB
      }).first {
        if cyb.balance.toDouble()! >= cyb_amount {
          let amount = getRealAmount(AssetConfiguration.CYB, amount: cyb_amount.string)
          completion(true, amount, AssetConfiguration.CYB)
        }
        else {
          let request = GetRequiredFees(response: { (data) in
            if let fees = data as? [Fee], let base_amount = fees.first?.amount.toDouble() {
              if let base = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
                return balance.asset_type == focus_asset_id
              }).first {
                if base.balance.toDouble()! >= base_amount {
                  let amount = getRealAmount(focus_asset_id, amount: base_amount.string)
                  completion(true, amount, focus_asset_id)
                }
                else {//余额不足
                  completion(false, 0, "")
                }
              }
              else {
                completion(false, 0, "")
              }
            }
            else {
              completion(false, 0, "")
            }
          }, operationStr: operation, assetID: focus_asset_id, operationID: operationID)
          
          WebsocketService.shared.send(request: request)
        }
      }
      else {
        completion(false, 0, "")
      }
      
    }
    else {
      completion(false, 0, "")
    }
  }, operationStr: operation, assetID: AssetConfiguration.CYB, operationID: operationID)
  
  WebsocketService.shared.send(request: request)
}
  
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

func saveImageToPhotos(){
  guard let window = UIApplication.shared.keyWindow else { return }
  
  UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0.0)
  
  window.layer.render(in: UIGraphicsGetCurrentContext()!)
  
  let image = UIGraphicsGetImageFromCurrentImageContext()
  
  UIGraphicsEndImageContext()
  
  UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
}


// 得到一个ID获取最后一个数据
func getUserId(_ userId:String)->Int{
  if userId.contains("."){
    return Int(String.init(userId.split(separator: ".").last!))!
  }
  return 0
}


func getWithdrawDetailInfo(addressInfo:String,amountInfo:String,withdrawFeeInfo:String,gatewayFeeInfo:String,receiveAmountInfo:String) -> [NSAttributedString]{
  let address :String = R.string.localizable.utils_address.key.localized()
  let amount : String = R.string.localizable.utils_amount.key.localized()
  let withdrawFee : String = R.string.localizable.utils_withdrawfee.key.localized()
  let gatewayFee : String = R.string.localizable.utils_gatewayfee.key.localized()
  let receiveAmount : String = R.string.localizable.utils_receiveamount.key.localized()
  
  return (["<name>\(String(describing: address))</name><content>\n\(String(describing: addressInfo))</content>".set(style: "alertContent"),
           "<name>\(String(describing: amount))</name><content>  \(String(describing: amountInfo))</content>".set(style: "alertContent"),
           "<name>\(String(describing: withdrawFee))</name><content>  \(String(describing: withdrawFeeInfo))</content>".set(style: "alertContent"),
           "<name>\(String(describing: gatewayFee))</name><content>  \(String(describing: gatewayFeeInfo))</content>".set(style: "alertContent"),
           "<name>\(String(describing: receiveAmount))</name><content>  \(String(describing: receiveAmountInfo))</content>".set(style: "alertContent")] as? [NSAttributedString])!
  
}

