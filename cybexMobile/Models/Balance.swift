//
//  Balance.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class Balance: HandyJSON {
    var assetType: String = "" //id
    var balance: String = ""

    required init() {

    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< assetType <-- ("asset_type", ToStringTransform())
        mapper <<< balance <-- ("balance", ToStringTransform())
    }

    func rmbValue() -> Decimal {
        var balanceValues: Decimal = 0

        let realAmount = AssetHelper.getRealAmount(assetType, amount: balance)
        let realRMBPrice = AssetHelper.singleAssetRMBPrice(assetType)

        balanceValues = realAmount * realRMBPrice

        return balanceValues
    }
}
