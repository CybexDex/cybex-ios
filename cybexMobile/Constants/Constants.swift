//
//  Constants.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

typealias CommonCallback = () -> Void
typealias CommonAnyCallback = (Any) -> Void

var appData: AppPropertyState {
    return AppConfiguration.shared.appCoordinator.state.property
}
var appState: AppState {
    return AppConfiguration.shared.appCoordinator.state
}
var appCoodinator: AppCoordinator {
    return AppConfiguration.shared.appCoordinator
}

struct NotificationName {
    static var NetWorkChanged = Notification.Name(rawValue: "NetWorkChanged")
}

struct AppConfiguration {
    static let shared = AppConfiguration()
    var appCoordinator: AppCoordinator!
    var chainID: String = ""

    private init() {
        let rootVC = BaseTabbarViewController()
        appCoordinator = AppCoordinator(rootVC: rootVC)
    }

    static let APPID = ""
    static var ServerBaseURLString = "https://app.cybex.io/"
    static var ServerRegisterBaseURLString = "https://faucet.cybex.io/"
    static var GatewayURLString = "https://gateway.cybex.io/gateway"
    static var ETOMGBaseURLString = URL(string: "https://eto.cybex.io/api")!
    static var ETOMGBaseTestURLString = URL(string: "https://ieo-apitest.cybex.io/api")!
    static var GatewayID = "CybexGateway" //CybexGatewayDev

    static var ServerIconsBaseURLString = "https://app.cybex.io/icons/"

    static var ServerRegisterPincodeURLString: String {
        return ServerRegisterBaseURLString + "captcha"
    }
    static var ServerRegisterURLString: String {
        return ServerRegisterBaseURLString + "register"
    }

    static var ServerVersionURLString: String {
        return ServerBaseURLString + "iOS_update.json"
    }

    static var ServerVersionAppstoreURLString: String {
        return ServerBaseURLString + "iOS_store_update.json"
    }

    static var ServerMarketListURLString: String {
        return ServerBaseURLString + "market_list?base="
    }

    static var FAQNightTheme            = "https://cybex.io/token_applications/new?style=night"
    static var FAQLightTheme            = "https://cybex.io/token_applications/new"

    static var ETHPrice: String {
        return ServerBaseURLString + "price"
    }
    static var WITHDRAW: String {
        return ServerBaseURLString + "json/withdraw.json"
    }
    static var DEPOSIT: String {
        return ServerBaseURLString + "json/deposit.json"
    }
    static var ASSET: String {
        return ServerBaseURLString + "json/assets.json"
    }
    //  json/withdraw_msg.json
    static var WithdrawMSG: String {
        return ServerBaseURLString + "json/withdraw_msg.json"
    }
    static var DepositMSG: String {
        return ServerBaseURLString + "json/deposit_msg.json"
    }

    static var MARKETLISTS: String {
        return  ServerBaseURLString + "json/marketlists.json"
    }

    static var RecodeBaseURLString = "https://gateway-query.cybex.io/"
    static var RecodeLogin = RecodeBaseURLString + "login"
    static var RecodeRecodes = RecodeBaseURLString + "records"
    static var RecodeAccountAsset = RecodeBaseURLString + "account-assets"

    static var HelpNightURL = "http://47.75.154.39:3009/cybexnight?lang="
    static var HelpLightURL = "http://47.75.154.39:3009/cybexday?lang="

    static var GatewayTestURLStringa = "https://gatewaytest.cybex.io/gateway"
    static var ServerRegisterBaseTestURLString = "https://faucet.51nebula.com/"
    static var ServerTestBaseURLString = "http://47.91.242.71:3039/"

    static var BaseSettingJson: String {
        return ServerBaseURLString + "json/settings.json"
    }

    static var HotAssetsJson: String {
        return ServerBaseURLString + "v1/api/hotpair"
    }

    static var AnnounceJson: String {
        return ServerBaseURLString + "v1/api/announce?lang="
    }

    static var HomeItemsJson: String {
        return ServerBaseURLString + "v1/api/app_sublinks?lang="
    }

    static var HomeBannerJson: String {
        return ServerBaseURLString + "v1/api/banners?lang="
    }

    static var BlockExplorerJson: String {
        return ServerBaseURLString + "json/blockexplorer.json"
    }
}

enum ExchangeType {
    case buy
    case sell
}

enum Indicator: String {
    case none
    case macd = "MACD"
    case ema = "EMA"
    case ma = "MA"
    case boll = "BOLL"

    static let all: [Indicator] = [.ma, .ema, .macd, .boll]
}

enum Candlesticks: Double, Hashable {
    case fiveMinute = 300.0
    case oneHour = 3600.0
    case oneDay = 86400.0

    static func ==(lhs: Candlesticks, rhs: Candlesticks) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    var hashValue: Int {
        return self.rawValue.int
    }

    static let all: [Candlesticks] = [.fiveMinute, .oneHour, .oneDay]
}

enum ChainTypesObjectType: Int {
    case null = 0
    case base
    case account
    case asset
    case forceSettlement
    case committeeMember
    case witness
    case limitOrder
    case callOrder
    case custom
    case proposal
    case operationHistory
    case withdrawPermission
    case vestingBalance
    case worker
    case balance
    case crowdfund
    case crowdfundContract
}

enum ChainTypesOperations: Int {
    case transfer = 0
    case limitOrderCreate
    case limitOrderCancel
    case callOrderUpdate
    case fillOrder
    case accountCreate
    case accountUpdate
    case accountWhitelist
    case accountUpgrade
    case accountTransfer
    case assetCreate
    case assetUpdate
    case assetUpdateBitasset
    case assetUpdateFeedProducers
    case assetIssue
    case assetReserve
    case assetFundFeePool
    case assetSettle
    case assetGlobalSettle
    case assetPublishFeed
    case witnessCreate
    case witnessUpdate
    case proposalCreate
    case proposalUpdate
    case proposalDelete
    case withdrawPermissionCreate
    case withdrawPermissionUpdate
    case withdrawPermissionClaim
    case withdrawPermissionDelete
    case committeeMemberCreate
    case committeeMemberUpdate
    case committeeMemberUpdateGlobalParameters
    case vestingBalanceCreate
    case vestingBalanceWithdraw
    case workerCreate
    case custom
    case assert
    case balanceClaim
    case overrideTransfer
    case transferToBlind
    case blindTransfer
    case transferFromBlind
    case assetSettleCancel
    case assetClaimFees
    case initiateCrowdfund
    case participateCrowdfund
    case withdrawCrowdfund
}

enum ObjectID: String {
    case baseObject = "1.1.0"
    case accountObject = "1.2.0"
    case assetObject = "1.3.0"
    case forceSettlementObject = "1.4.0"
    case committeeMemberObject = "1.5.0"
    case witnessObject = "1.6.0"
    case limitOrderObject = "1.7.0"
    case callOrderObject = "1.8.0"
    case customObject = "1.9.0"
    case proposalObject = "1.10.0"
    case operationHistoryObject = "1.11.0"
    case withdrawPermissionObject = "1.12.0"
    case vestingBalanceObject = "1.13.0"
    case workerObject = "1.14.0"
    case balanceObject = "1.15.0"
    case globalPropertyObject = "2.0.0"
    case dynamicGlobalPropertyObject = "2.1.0"
    case assetDynamicData = "2.3.0"
    case assetDitassetData = "2.4.0"
    case accountBalanceObject = "2.5.0"
    case accountStatisticsObject = "2.6.0"
    case transactionObject = "2.7.0"
    case blockSummaryObject = "2.8.0"
    case accountTransactionHistoryObject = "2.9.0"
    case blindedBalanceObject = "2.10.0"
    case chainPropertyObject = "2.11.0"
    case witnessScheduleObject = "2.12.0"
    case budgetRecordObject = "2.13.0"
    case specialAuthorityObject = "2.14.0"
}

class AssetConfiguration {
    var assetIds: [Pair] = []

    // 正式
    static var CYB = "1.3.0"
    static var BTC = "1.3.3"
    static var ETH = "1.3.2"
    static var EOS = "1.3.4"
    static let USDT = "1.3.27"
    
    // 测试
//    static var CYB = "1.3.0"
//    static var USDT = "1.3.56"
//    static var BTC = "1.3.58"
//    static var ETH = "1.3.53"
//    static var EOS = "1.3.57"
//    static var LTC = "1.3.60"
//    static var KEY = "1.3.59"

    static let orderName = ["USDT", "ETH", "BTC", "CYB"]
    static var marketBaseAssets = [AssetConfiguration.ETH, AssetConfiguration.CYB, AssetConfiguration.USDT, AssetConfiguration.BTC]

    var uniqueIds: [String] = []
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
