//
//  AssetInfo.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/27.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class AssetInfo: HandyJSON {
    var precision: Int = 0
    var id: String = ""
    var symbol: String = ""
    var dynamicAssetDataId: String = ""

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<< precision            <-- "precision"
        mapper <<< id                   <--  "id"
        mapper <<< symbol               <--  "symbol"
        mapper <<< dynamicAssetDataId <--  "dynamic_asset_data_id"
    }
}

class Asset: HandyJSON {
    var amount: String = ""
    var assetID: String = ""

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<< amount               <-- ("amount", ToStringTransform())
        mapper <<< assetID              <-- "asset_id"
    }

    func volume() -> Double {
        let info = appData.assetInfo[assetID]!

        return Double(amount)! / pow(10, info.precision.double)
    }

    func info() -> AssetInfo {
        return appData.assetInfo[self.assetID] ?? AssetInfo()
    }
}

extension Asset: Equatable {
    static func ==(lhs: Asset, rhs: Asset) -> Bool {
        return lhs.assetID == rhs.assetID
    }
}

class Price: HandyJSON {
    var base: Asset = Asset()
    var quote: Asset = Asset()

    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< base                    <-- "base"
        mapper <<< quote                   <-- "quote"
    }

    func toReal() -> Double {
        let baseInfo = base.info()
        let quoteInfo = quote.info()

        if let baseDouble = Double(base.amount), let quoteDouble = Double(quote.amount), quoteDouble != 0 {
            let priceRatio =  baseDouble / quoteDouble

            let baseNumber = NSDecimalNumber(floatLiteral: pow(10, baseInfo.precision.double))
            let quoteNumber = NSDecimalNumber(floatLiteral: pow(10, quoteInfo.precision.double))

            let precisionRatio = baseNumber.dividing(by: quoteNumber).stringValue

            return priceRatio / precisionRatio.toDouble()!
        }

        return 0
    }

}

extension AssetInfo: Equatable {
    static func ==(lhs: AssetInfo, rhs: AssetInfo) -> Bool {
        return lhs.precision == rhs.precision && lhs.id == rhs.id && lhs.symbol == rhs.symbol && lhs.dynamicAssetDataId == rhs.dynamicAssetDataId
    }
}

struct RMBPrices {
    var name: String      = ""
    var rmbPrice: String = ""
}

struct ImportantMarketPair {
    var base: String = ""
    var quotes: [String] = [String]()
}
