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
            return !currency.percentChange.contains("-") && !MarketConfiguration.shared.gameMarketPairs.contains(Pair(base: currency.base, quote: currency.quote))
        }
        return counts.sorted(by: { (currency1, currency2) -> Bool in
            let change1 = currency1.percentChange
            let change2 = currency2.percentChange
            return change1.decimal() > change2.decimal()
        })
    }

    class func getTickerByPair(_ pair: Pair?) -> Ticker? {
        guard let pair = pair else { return nil }
        return appData.tickerData.value.filter { (ticker) -> Bool in
            return ticker.base == pair.base && ticker.quote == pair.quote
        }.first
    }

    class func calculateAssetRelation(assetIDAName: String, assetIDBName: String) -> (base: String, quote: String) { // asset 只需要过滤Jade
        let relation: [String] = [AssetConfiguration.CybexAsset.USDT.rawValue,
                                  AssetConfiguration.CybexAsset.ETH.rawValue,
                                  AssetConfiguration.CybexAsset.BTC.rawValue,
                                  AssetConfiguration.CybexAsset.CYB.rawValue]

        let filterSymbolA = assetIDAName.filterSystemPrefix
        let filterSymbolB = assetIDBName.filterSystemPrefix

        var indexA = -1
        var indexB = -1

        if let index = relation.firstIndex(of: filterSymbolA) {
            indexA = index
        }
        
        if let index = relation.firstIndex(of: filterSymbolB) {
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


