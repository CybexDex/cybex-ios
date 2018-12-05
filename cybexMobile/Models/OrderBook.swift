//
//  OrderBook.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/10.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class LimitOrder: HandyJSON {
    var id: String = ""
    var expiration: String = ""
    var seller: String = ""
    var forSale: String = ""
    var sellPrice: Price = Price()
    var quoteAmount: String = ""
    /*
     1 sellPrice里面的base 和quote
     2 根据关系判断是买还是卖
     3 买的情况下 真正的base == sellPrice.base 卖的情况下 真正的base = sellPrice.quote
     4 手续费拿取。  买的时候是真正的base
     */
    var isBuy: Bool {
        let assetAInfo = appData.assetInfo[sellPrice.base.assetID]
        let assetBInfo = appData.assetInfo[sellPrice.quote.assetID]

        let (base, _) = calculateAssetRelation(assetIDAName: (assetAInfo != nil) ? assetAInfo!.symbol.filterJade : "", assetIDBName: (assetBInfo != nil) ? assetBInfo!.symbol.filterJade : "")

        return (base == ((assetAInfo != nil) ? assetAInfo!.symbol.filterJade : ""))
    }

    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< id                   <-- "id"
        mapper <<< expiration           <-- "expiration"
        mapper <<< seller               <-- "seller"
        mapper <<< forSale              <-- ("for_sale", ToStringTransform())
        mapper <<< sellPrice            <-- "sell_price"
    }

}
