//
//  AssetHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

class AssetHelper {
    class func getPrecision(_ assetID: String) -> Int? {
        if let info = appData.assetInfo[assetID] {
            return info.precision
        }
        return nil
    }

    class func getPrecisionWith(_ assetName: String) -> Int? {
        if let assetID = getAssetId(assetName) {
            return getPrecision(assetID)
        }

        return nil
    }

    class func getAssetId(_ assetName: String) -> String? {
        if let assetId = appData.assetNameToIds.value[assetName] {
            return assetId
        }

        return nil
    }

    class func singleAssetRMBPrice(_ assetID: String) -> Decimal {
        if let baseAsset = AssetConfiguration.CybexAsset(assetID), MarketConfiguration.marketBaseAssets.contains(baseAsset) {
            return AssetConfiguration.shared.rmbOf(asset: baseAsset)
        }
        for asset in CybexConfiguration.portfolioOutPriceBaseOrderAsset {
            let tickers = appData.tickerData.value.filter { (ticker) -> Bool in
                return ticker.base == asset.id && ticker.quote == assetID
            }
            if let ticker = tickers.first, let baseAsset = AssetConfiguration.CybexAsset(ticker.base) {
                return ticker.latest.decimal() * AssetConfiguration.shared.rmbOf(asset: baseAsset)
            }
        }
        return 0
    }

    class func getRealAmount(_ id: String, amount: String) -> Decimal {
        guard let asset = appData.assetInfo[id] else {
            return 0
        }

        let precisionNumber = pow(10, asset.precision)

        return amount.decimal() / precisionNumber
    }

    class func setRealAmount(_ id: String, amount: String) -> Decimal {
        guard let asset = appData.assetInfo[id] else {
            return 0
        }

        let value = pow(10, asset.precision)

        return amount.decimal() * value
    }
}
