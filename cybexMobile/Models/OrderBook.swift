//
//  OrderBook.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/10.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON


/// 链上记录的是卖base 买quote的单
class LimitOrder: HandyJSON {
    var id: String = ""
    var expiration: String = ""
    var seller: String = ""
    var forSale: String = "" // sellPrice 没有成交的里面的base
    var sellPrice: Price = Price()
    var quoteAmount: String = ""
    
    var baseID: String = ""
    /*
     1 sellPrice里面的base 和quote
     2 根据关系判断是买还是卖
     3 买卖针对于quote的话  真正的base == sellPrice.base 是买单 ，真正的base = sellPrice.quote 是卖单
     */
    var isBuy: Bool {
        let assetAInfo = appData.assetInfo[sellPrice.base.assetID]
        let assetBInfo = appData.assetInfo[sellPrice.quote.assetID]

        let (base, _) = MarketHelper.calculateAssetRelation(
            assetIDAName: (assetAInfo != nil) ?
                assetAInfo!.symbol.filterOnlySystemPrefix : "",
            assetIDBName: (assetBInfo != nil) ?
                assetBInfo!.symbol.filterOnlySystemPrefix : "")

        return (base == ((assetAInfo != nil) ? assetAInfo!.symbol : ""))
    }

    var price: Decimal {
        if (direction == "buy") {
            return AssetHelper.getRealAmount(sellPrice.base.assetID, amount: sellPrice.base.amount) /  AssetHelper.getRealAmount(sellPrice.quote.assetID, amount: sellPrice.quote.amount)
        } else {
            return AssetHelper.getRealAmount(sellPrice.quote.assetID, amount: sellPrice.quote.amount) / AssetHelper.getRealAmount(sellPrice.base.assetID, amount: sellPrice.base.amount)
        }
    }
    
    var left_amount: Decimal {
        let realAmount = AssetHelper.getRealAmount(sellPrice.base.assetID, amount: forSale)
        if (direction == "buy") {
            return realAmount / price
        } else {
            return realAmount
        }
    }
    
    var direction: String { //buy sell
        return sellPrice.base.assetID == baseID ? "buy" : "sell"
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

    func rmbValue() -> Decimal {
        let realAmount = AssetHelper.getRealAmount(sellPrice.base.assetID, amount: forSale)
        let priceValue = AssetHelper.singleAssetRMBPrice(sellPrice.base.assetID)
        let decimallimitOrderValue: Decimal = realAmount * priceValue

        return decimallimitOrderValue
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

    func getAveragePrice() -> Price {
        let pair = self.getPair()
        return self.isBuyOrder() ? Price(base: Asset(amount: self.soldAmount.string, assetID: pair.base),
                                         quote: Asset(amount: self.receivedAmount.string, assetID: pair.quote)) :
            Price(base: Asset(amount: self.receivedAmount.string, assetID: pair.base),
                  quote: Asset(amount: self.soldAmount.string, assetID: pair.quote))
    }
    
    func getPair() -> Pair {
        let assetAInfo = appData.assetInfo[self.asset1]
        let assetBInfo = appData.assetInfo[self.asset2]
        let (base, quote) = MarketHelper.calculateAssetRelation(
            assetIDAName: (assetAInfo != nil) ?
                assetAInfo!.symbol.filterOnlySystemPrefix : "",
            assetIDBName: (assetBInfo != nil) ?
                assetBInfo!.symbol.filterOnlySystemPrefix : "")
        
        return Pair(base: base.assetID, quote: quote.assetID)
    }
    
    func decimalProgress() -> Decimal {
        if self.isBuyOrder() {
            return Decimal(receivedAmount) / Decimal(amountToReceive) * 100
        }
        return Decimal(soldAmount) / Decimal(amountToSell) * 100
    }
}
