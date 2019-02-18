//
//  MarketHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

class MarketHelper {
    class func filterQuoteAssetTicker(_ base: String) -> [Ticker] {
        return appData.tickerData.value.filter({ (currency) -> Bool in
            return currency.base == base
        })
    }

    class func filterPopAssetsCurrency() -> [Ticker] {
        let counts = appData.tickerData.value.filter { (currency) -> Bool in
            return !currency.percentChange.contains("-")
        }
        return counts.sorted(by: { (currency1, currency2) -> Bool in
            let change1 = currency1.percentChange
            let change2 = currency2.percentChange
            return change1.decimal() > change2.decimal()
        })
    }

    class func calculateAssetRelation(assetIDAName: String, assetIDBName: String) -> (base: String, quote: String) {
        let relation: [String] = [AssetConfiguration.CybexAsset.USDT.rawValue,
                                  AssetConfiguration.CybexAsset.ETH.rawValue,
                                  AssetConfiguration.CybexAsset.BTC.rawValue,
                                  AssetConfiguration.CybexAsset.CYB.rawValue]

        var indexA = -1
        var indexB = -1

        if let index = relation.index(of: assetIDAName) {
            indexA = index
        }
     
        if let index = relation.index(of: assetIDBName) {
            indexB = index
        }

        if indexA > -1 && indexB > -1 {
            if indexA < indexB {
                return (assetIDAName, assetIDBName)
            } else {
                return (assetIDBName, assetIDAName)
            }
        } else if indexA < indexB {
            return (assetIDBName, assetIDAName)
        } else if indexA > indexB {
            return (assetIDAName, assetIDBName)
        } else {
            if assetIDAName < assetIDBName {
                return (assetIDAName, assetIDBName)
            } else {
                return (assetIDBName, assetIDAName)
            }
        }
    }
}


