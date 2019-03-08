//
//  Operation.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class Transfer: HandyJSON, NSCopying {
    var from: String = ""
    var to: String = ""
    var fee: Asset = Asset()
    var amount: Asset = Asset()

    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< from                   <-- ("from", ToStringTransform())
        mapper <<< to          <-- ("to", ToStringTransform())
        mapper <<< fee         <-- "fee"
        mapper <<< amount            <-- "amount"
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Transfer.deserialize(from: self.toJSON())
        return copy ?? Transfer()
    }

    static func empty() -> Transfer {
        return Transfer()
    }
}

class FillOrder: HandyJSON, NSCopying {
    var fillPrice: Price = Price()
    var fee: Asset = Asset()
    var pays: Asset = Asset()
    var receives: Asset = Asset()
    var isMaker: Int = 0 //0 1
    var blockNum: Int = 0

    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< fillPrice                   <-- "fill_price"
        mapper <<< fee                   <-- "fee"
        mapper <<< pays                   <-- "pays"
        mapper <<< receives                   <-- "receives"
        mapper <<< isMaker                   <-- "is_maker"
        mapper <<< blockNum                   <-- "block_num"
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = FillOrder.deserialize(from: self.toJSON())
        return copy ?? FillOrder()
    }

    static func empty() -> FillOrder {
        return FillOrder()
    }

    func getPair() -> Pair {
        let assetAName = pays.assetID.symbolOnlyFilterJade
        let assetBName = receives.assetID.symbolOnlyFilterJade

        let (base, quote) = MarketHelper.calculateAssetRelation(
            assetIDAName: assetAName,
            assetIDBName: assetBName)

        return Pair(base: base.assetID, quote: quote.assetID)
    }

    func isBuyOrder() -> Bool {
        let pair = self.getPair()

        return pair.base == pays.assetID
    }

    func getPrice() -> Price {
        let base = getPair().base
        if base == fillPrice.base.assetID {
            return fillPrice
        }
        else {
            return fillPrice.reverse()
        }
    }

}
