//
//  AssetInfo.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/27.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper
import HandyJSON

class AssetInfo: Mappable {
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

class Asset: Mappable {
    var amount: String = ""
    var assetID: String = ""

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        amount               <- (map["amount"], ToStringTransform())
        assetID              <- map["asset_id"]
    }

    func volume() -> Double {
        let info = appData.assetInfo[assetID]!

        return Double(amount)! / pow(10, info.precision.double)
    }

    func info() -> AssetInfo {
        return appData.assetInfo[self.assetID] ?? AssetInfo(JSON: [:])!
    }
}

extension Asset: Equatable {
    static func ==(lhs: Asset, rhs: Asset) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

class Price: Mappable {
    var base: Asset = Asset(JSON: [:])!
    var quote: Asset = Asset(JSON: [:])!

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        base                    <- map["base"]
        quote                   <- map["quote"]
    }

    func toReal() -> Double {
        let base_info = base.info()
        let quote_info = quote.info()

        let price_ratio =  Double(base.amount)! / Double(quote.amount)!

        let baseNumber = NSDecimalNumber(floatLiteral: pow(10, base_info.precision.double))
        let quoteNumber = NSDecimalNumber(floatLiteral: pow(10, quote_info.precision.double))

        let precision_ratio = baseNumber.dividing(by: quoteNumber).stringValue

        return price_ratio / precision_ratio.toDouble()!
    }

}

extension AssetInfo: Equatable {
    static func ==(lhs: AssetInfo, rhs: AssetInfo) -> Bool {
        return lhs.precision == rhs.precision && lhs.id == rhs.id && lhs.symbol == rhs.symbol && lhs.dynamic_asset_data_id == rhs.dynamic_asset_data_id
    }
}

struct RMBPrices {
    var name: String      = ""
    var rmb_price: String = ""
}

struct ImportantMarketPair {
    var base: String = ""
    var quotes: [String] = [String]()
}
