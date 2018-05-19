//
//  Constants.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

typealias CommonCallback = () -> Void
typealias CommonAnyCallback = (Any) -> Void

var app_data: AppPropertyState {
  return UIApplication.shared.coordinator().state.property
}
var app_state: AppState {
  return UIApplication.shared.coordinator().state
}
var app_coodinator:AppCoordinator {
  return UIApplication.shared.coordinator()
}

struct AppConfiguration {
  static let APPID = ""
  static let SERVER_BASE_URLString = "https://app.cybex.io/"
  static let SERVER_ICONS_BASE_URLString = "https://app.cybex.io/icons/"

  static let SERVER_VERSION_URLString = SERVER_BASE_URLString + "iOS_update.json"
  static let SERVER_MARKETLIST_URLString = SERVER_BASE_URLString + "market_list.json"
  
  static let FAQ_NIGHT_THEME            = "https://cybex.io/token_applications/new?style=night"
  static let FAQ_LIGHT_THEME            = "https://cybex.io/token_applications/new"
  
  static let ETH_PRICE                  = SERVER_BASE_URLString + "price"
}

enum indicator:String {
  case none
  case macd = "MACD"
  case ema = "EMA"
  case ma = "MA"
  case boll = "BOLL"
  
  static let all:[indicator] = [.ma, .ema, .macd, .boll]
}

enum candlesticks:Double,Hashable {
  case five_minute = 300.0
  case one_hour = 3600.0
  case one_day = 86400.0
  
  static func ==(lhs: candlesticks, rhs: candlesticks) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
  
  var hashValue: Int {
    return self.rawValue.toInt
  }
  
  static let all:[candlesticks] = [.five_minute, .one_hour, .one_day]
}

enum objectID:String {
  case base_object = "1.1.x"
  case account_object = "1.2.x"
  case asset_object = "1.3.x"
  case force_settlement_object = "1.4.x"
  case committee_member_object = "1.5.x"
  case witness_object = "1.6.x"
  case limit_order_object = "1.7.x"
  case call_order_object = "1.8.x"
  case custom_object = "1.9.x"
  case proposal_object = "1.10.x"
  case operation_history_object = "1.11.x"
  case withdraw_permission_object = "1.12.x"
  case vesting_balance_object = "1.13.x"
  case worker_object = "1.14.x"
  case balance_object = "1.15.x"
  case global_property_object = "2.0.x"
  case dynamic_global_property_object = "2.1.x"
  case asset_dynamic_data = "2.3.x"
  case asset_bitasset_data = "2.4.x"
  case account_balance_object = "2.5.x"
  case account_statistics_object = "2.6.x"
  case transaction_object = "2.7.x"
  case block_summary_object = "2.8.x"
  case account_transaction_history_object = "2.9.x"
  case blinded_balance_object = "2.10.x"
  case chain_property_object = "2.11.x"
  case witness_schedule_object = "2.12.x"
  case budget_record_object = "2.13.x"
  case special_authority_object = "2.14.x"
}

class AssetConfiguration {  
  var asset_ids:[Pair] = []
  
  static let CYB = "1.3.0"
  
  var unique_ids:[String] {
    return asset_ids.map({[$0.base, $0.quote]}).flatMap({ $0 }).unique()
  }
  
  private init() {
  }
  
  static let shared = AssetConfiguration()
}



protocol ObjectDescriptable {
  func propertyDescription() -> String
}

extension ObjectDescriptable {
  func propertyDescription() -> String {
    let strings = Mirror(reflecting: self).children.flatMap { "\($0.label!): \($0.value)" }
    var string = ""
    for str in strings {
      string += String(str) + "\n"
    }
    return string
  }
}

