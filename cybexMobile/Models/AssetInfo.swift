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
 
    init(amount: String, assetID: String) {
        self.amount = amount
        self.assetID = assetID
    }
    
    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<< amount               <-- ("amount", ToStringTransform())
        mapper <<< assetID              <-- "asset_id"
    }

    func volume() -> Decimal {
        let info = appData.assetInfo[assetID]!

        return amount.decimal() / pow(10, info.precision)
    }

    func volumeWith(_ precision: Int) -> Decimal {
        return amount.decimal() / pow(10, precision)
    }

    func volumeString() -> String {
        let info = appData.assetInfo[assetID]!

        return (amount.decimal() / pow(10, info.precision)).suffixNumber(digitNum: info.precision, padZero: true)
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
    
    init(base: Asset, quote: Asset) {
        self.base = base
        self.quote = quote
    }
    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< base                    <-- "base"
        mapper <<< quote                   <-- "quote"
    }

    func toReal() -> Decimal {
        let baseInfo = base.info()
        let quoteInfo = quote.info()
        let baseDouble = base.amount.decimal()
        let quoteDouble = quote.amount.decimal()

        if quoteDouble != 0 {
            let priceRatio =  baseDouble / quoteDouble

            //            let baseNumber = NSDecimalNumber(floatLiteral: pow(10, baseInfo.precision.double))
            //            let quoteNumber = NSDecimalNumber(floatLiteral: pow(10, quoteInfo.precision.double))
            let baseNumber = pow(10, baseInfo.precision)
            let quoteNumber = pow(10, quoteInfo.precision)

            //            let precisionRatio = baseNumber.dividing(by: quoteNumber).stringValue
            let precisionRatio = baseNumber / quoteNumber


            //            print("base.amount : \(base.amount), baseNumber: \(baseNumber), quote.amount: \(quote.amount), quoteNumber:\(quoteNumber)")
            return priceRatio / precisionRatio
        }

        return 0
    }
}

extension AssetInfo: Equatable {
    static func ==(lhs: AssetInfo, rhs: AssetInfo) -> Bool {
        return lhs.precision == rhs.precision && lhs.id == rhs.id && lhs.symbol == rhs.symbol && lhs.dynamicAssetDataId == rhs.dynamicAssetDataId
    }
}

struct RMBPrices: HandyJSON {
    var name: String      = ""
    var value: String = "0"
    var time: Int = 0
}

struct ImportantMarketPair {
    var base: String = ""
    var quotes: [String] = [String]()
}
