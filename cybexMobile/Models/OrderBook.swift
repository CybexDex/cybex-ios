//
//  OrderBook.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/10.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class LimitOrder: Mappable {
    var id: String = ""
    var expiration: String = ""
    var seller: String = ""
    var forSale: String = ""
    var sellPrice: Price = Price(JSON: [:])!

    /*
     1 sellPrice里面的base 和quote
     2 根据关系判断是买还是卖
     3 买的情况下 真正的base == sellPrice.base 卖的情况下 真正的base = sellPrice.quote
     4 手续费拿取。  买的时候是真正的base
     */
    var isBuy: Bool {
        let assetA_info = app_data.assetInfo[sellPrice.base.assetID]
        let assetB_info = app_data.assetInfo[sellPrice.quote.assetID]

        let (base, _) = calculateAssetRelation(assetIDAName: (assetA_info != nil) ? assetA_info!.symbol.filterJade : "", assetIDBName: (assetB_info != nil) ? assetB_info!.symbol.filterJade : "")

        return (base == ((assetA_info != nil) ? assetA_info!.symbol.filterJade : ""))
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id                   <- map["id"]
        expiration           <- map["expiration"]
        seller               <- map["seller"]
        forSale              <- (map["for_sale"], ToStringTransform())
        sellPrice            <- map["sell_price"]
    }

}
