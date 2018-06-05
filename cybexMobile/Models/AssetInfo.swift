//
//  AssetInfo.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/27.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class AssetInfo : Mappable {
  var precision: Int = 0
  var id: String = ""
  var symbol: String = ""
  var dynamic_asset_data_id: String = ""


  required init?(map: Map) {
  }

  func mapping(map: Map) {
    precision            <- map["precision"]
    id                   <-  map["id"]
    symbol               <-  map["symbol"]
    dynamic_asset_data_id <-  map["dynamic_asset_data_id"]
  }
}



class Asset : Mappable {
  var amount: String = ""
  var assetID: String = ""
  
  required init?(map: Map) {
  }
  
  func mapping(map: Map) {
    amount               <- (map["amount"], ToStringTransform())
    assetID              <- map["asset_id"]
  }
  
  func volume() -> Double {
    let info = app_data.assetInfo[assetID]!
    
    return Double(amount)! / pow(10, info.precision.double)
  }
  
  func info() -> AssetInfo {
    return app_data.assetInfo[self.assetID]!
  }
}

extension Asset: Equatable {
  static func ==(lhs: Asset, rhs: Asset) -> Bool {
    return lhs.assetID == rhs.assetID
  }
}

class Price : ImmutableMappable {
  let base:Asset
  let quote:Asset
  
  required  init(map: Map) throws {
    base                    = try map.value("base")
    quote                   = try map.value("quote")
  }
  
  func mapping(map: Map) {
    base                    >>> map["base"]
    quote                   >>> map["quote"]
  }
  
  func toReal() -> Double {
    let base_info = base.info()
    let quote_info = quote.info()
    
    let price_ratio =  Double(base.amount)! / Double(quote.amount)!
    let precision_ratio = pow(10, base_info.precision.double) / pow(10, quote_info.precision.double)
    
    return price_ratio / precision_ratio
  }
  
}

extension AssetInfo: Equatable {
  static func ==(lhs: AssetInfo, rhs: AssetInfo) -> Bool {
    return lhs.precision == rhs.precision && lhs.id == rhs.id && lhs.symbol == rhs.symbol && lhs.dynamic_asset_data_id == rhs.dynamic_asset_data_id
  }
}

struct  RMBPrices{
  var name : String      = ""
  var rmb_price : String = ""
} 

