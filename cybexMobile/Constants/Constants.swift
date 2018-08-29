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
    return AppConfiguration.shared.appCoordinator.state.property
}
var app_state: AppState {
    return AppConfiguration.shared.appCoordinator.state
}
var app_coodinator:AppCoordinator {
    return AppConfiguration.shared.appCoordinator
}

struct AppConfiguration {
    static let shared = AppConfiguration()
    var appCoordinator: AppCoordinator!
    var chainID:String = ""
    
    private init() {
        let rootVC = BaseTabbarViewController()
        appCoordinator = AppCoordinator(rootVC: rootVC)
    }
    
    static let APPID = ""
    static let SERVER_BASE_URLString = "https://app.cybex.io/"
    static let SERVER_REGISTER_BASE_URLString = "https://faucet.cybex.io/"
    static let GATEWAY_URLString = "https://gateway.cybex.io/gateway"
    static let ETO_MG_BASE_URLString = URL(string:"https://eto.cybex.io/api")!
    static let GATEWAY_ID = "CybexGateway" //CybexGatewayDev
    
    static let SERVER_ICONS_BASE_URLString = "https://app.cybex.io/icons/"
    
    static let SERVER_REGISTER_PINCODE_URLString = SERVER_REGISTER_BASE_URLString + "captcha"
    static let SERVER_REGISTER_URLString = SERVER_REGISTER_BASE_URLString + "register"
    
    static let SERVER_VERSION_URLString = SERVER_BASE_URLString + "iOS_update.json"
    static let SERVER_MARKETLIST_URLString = SERVER_BASE_URLString + "market_list?base="
    
    static let FAQ_NIGHT_THEME            = "https://cybex.io/token_applications/new?style=night"
    static let FAQ_LIGHT_THEME            = "https://cybex.io/token_applications/new"
    
    static let ETH_PRICE                  = SERVER_BASE_URLString + "price"
    static let WITHDRAW                   = SERVER_BASE_URLString + "json/withdraw.json"
    static let DEPOSIT                    = SERVER_BASE_URLString + "json/deposit.json"
    static let ASSET                      = SERVER_BASE_URLString + "json/assets.json"
    //  json/withdraw_msg.json
    static let WITHDRAW_MSG               = SERVER_BASE_URLString + "json/withdraw_msg.json"
    static let DEPOSIT_MSG                = SERVER_BASE_URLString + "json/deposit_msg.json"
    
    static let MARKETLISTS                = SERVER_BASE_URLString + "json/marketlists.json"
    
    static let RECODE_BASE_URLString = "https://gateway-query.cybex.io/"
    static let RECODE_LOGIN = RECODE_BASE_URLString + "login"
    static let RECODE_RECODES = RECODE_BASE_URLString + "records"
}

enum exchangeType {
    case buy
    case sell
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
        return self.rawValue.int
    }
    
    static let all:[candlesticks] = [.five_minute, .one_hour, .one_day]
}

enum ChainTypesObjectType:Int {
    case null = 0
    case base
    case account
    case asset
    case force_settlement
    case committee_member
    case witness
    case limit_order
    case call_order
    case custom
    case proposal
    case operation_history
    case withdraw_permission
    case vesting_balance
    case worker
    case balance
    case crowdfund
    case crowdfund_contract
}

enum ChainTypesOperations:Int {
    case transfer = 0
    case limit_order_create
    case limit_order_cancel
    case call_order_update
    case fill_order
    case account_create
    case account_update
    case account_whitelist
    case account_upgrade
    case account_transfer
    case asset_create
    case asset_update
    case asset_update_bitasset
    case asset_update_feed_producers
    case asset_issue
    case asset_reserve
    case asset_fund_fee_pool
    case asset_settle
    case asset_global_settle
    case asset_publish_feed
    case witness_create
    case witness_update
    case proposal_create
    case proposal_update
    case proposal_delete
    case withdraw_permission_create
    case withdraw_permission_update
    case withdraw_permission_claim
    case withdraw_permission_delete
    case committee_member_create
    case committee_member_update
    case committee_member_update_global_parameters
    case vesting_balance_create
    case vesting_balance_withdraw
    case worker_create
    case custom
    case assert
    case balance_claim
    case override_transfer
    case transfer_to_blind
    case blind_transfer
    case transfer_from_blind
    case asset_settle_cancel
    case asset_claim_fees
    case initiate_crowdfund
    case participate_crowdfund
    case withdraw_crowdfund
}

enum objectID:String {
    case base_object = "1.1.0"
    case account_object = "1.2.0"
    case asset_object = "1.3.0"
    case force_settlement_object = "1.4.0"
    case committee_member_object = "1.5.0"
    case witness_object = "1.6.0"
    case limit_order_object = "1.7.0"
    case call_order_object = "1.8.0"
    case custom_object = "1.9.0"
    case proposal_object = "1.10.0"
    case operation_history_object = "1.11.0"
    case withdraw_permission_object = "1.12.0"
    case vesting_balance_object = "1.13.0"
    case worker_object = "1.14.0"
    case balance_object = "1.15.0"
    case global_property_object = "2.0.0"
    case dynamic_global_property_object = "2.1.0"
    case asset_dynamic_data = "2.3.0"
    case asset_bitasset_data = "2.4.0"
    case account_balance_object = "2.5.0"
    case account_statistics_object = "2.6.0"
    case transaction_object = "2.7.0"
    case block_summary_object = "2.8.0"
    case account_transaction_history_object = "2.9.0"
    case blinded_balance_object = "2.10.0"
    case chain_property_object = "2.11.0"
    case witness_schedule_object = "2.12.0"
    case budget_record_object = "2.13.0"
    case special_authority_object = "2.14.0"
}

class AssetConfiguration {  
    var asset_ids:[Pair] = []
    
    static let CYB = "1.3.0"
    static let BTC = "1.3.3"
    static let EOS = "1.3.4"
    static let ETH = "1.3.2"
    static let USDT = "1.3.27"
    
    static let order_name = ["USDT","ETH", "BTC", "CYB"]
    static let market_base_assets = [AssetConfiguration.ETH,AssetConfiguration.CYB,AssetConfiguration.USDT,AssetConfiguration.BTC]
    
    var unique_ids:[String] = []
    //    return asset_ids.map({[$0.base, $0.quote]}).flatMap({ $0 }).withoutDuplicates()
    
    
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

