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

        let (base, _) = MarketHelper.calculateAssetRelation(
            assetIDAName: (assetAInfo != nil) ?
                assetAInfo!.symbol.filterJade : "",
            assetIDBName: (assetBInfo != nil) ?
                assetBInfo!.symbol.filterJade : "")

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

class LimitOrderStatus: HandyJSON {
    var orderId: String!
    var seller: String!
    var isSellAsset1: Bool!
    var asset1: String!
    var asset2: String!
    var amountToSell: Int!
    var amountToReceive: Int!
    var soldAmount: Int!
    var receivedAmount: Int!
    var canceledAmount: Int!
    var createTime: Date!

    required init() {}
    func mapping(mapper: HelpingMapper) {
        mapper <<< orderId <-- "order_id"
        mapper <<< isSellAsset1 <-- "is_sell"
        mapper <<< asset1 <-- "key.asset1"
        mapper <<< asset2 <-- "key.asset2"
        mapper <<< amountToSell <-- "amount_to_sell"
        mapper <<< amountToReceive <-- "min_to_receive"
        mapper <<< soldAmount <-- "sold"
        mapper <<< receivedAmount <-- "received"
        mapper <<< canceledAmount <-- "canceled"
        mapper <<< createTime <-- ("create_time", GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss"))
    }
    
    func isBuyOrder() -> Bool {
        let pair = self.getPair()
        if (pair.base == asset1 && self.isSellAsset1 == true) ||
            (pair.base != asset1 && self.isSellAsset1 == false) {
            return true
        }
        return false
    }
    
    func getPrice() -> Price {
        let pair = self.getPair()
        return self.isBuyOrder() ? Price(base: Asset(amount: self.amountToSell.string, assetID: pair.base),
                                        quote: Asset(amount: self.amountToReceive.string, assetID: pair.quote)) :
                                   Price(base: Asset(amount: self.amountToReceive.string, assetID: pair.base),
                                        quote: Asset(amount: self.amountToSell.string, assetID: pair.quote))
    }
    
    func getPair() -> Pair {
        let assetAInfo = appData.assetInfo[self.asset1]
        let assetBInfo = appData.assetInfo[self.asset2]
        let (base, quote) = MarketHelper.calculateAssetRelation(
            assetIDAName: (assetAInfo != nil) ?
                assetAInfo!.symbol.filterJade : "",
            assetIDBName: (assetBInfo != nil) ?
                assetBInfo!.symbol.filterJade : "")
        
        return Pair(base: base.assetID, quote: quote.assetID)
    }
    
    func decimalProgress() -> Decimal {
        if self.isBuyOrder() {
            return Decimal(receivedAmount) / Decimal(amountToReceive) * 100
        }
        return Decimal(soldAmount) / Decimal(amountToSell) * 100
    }
}
