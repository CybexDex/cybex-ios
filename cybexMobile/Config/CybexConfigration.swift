//
//  CybexConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

class CybexConfiguration {
    static let shared = CybexConfiguration()

    static let portfolioOutPriceBaseOrderAsset = [
        AssetConfiguration.CybexAsset.CYB,
        AssetConfiguration.CybexAsset.USDT,
        AssetConfiguration.CybexAsset.ETH,
        AssetConfiguration.CybexAsset.BTC]

    var chainID: String = ""

    static var TransactionExpiration: TimeInterval = 45

    private init() {

    }
}
