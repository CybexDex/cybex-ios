//
//  Demo.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/17.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct Ticker: HandyJSON, Hashable {
    var base: String = ""
    var baseVolume: String = ""
    var latest: String = ""
    var time: Date?
    var highestBid: String = ""
    var quoteVolume: String = ""
    var lowestAsk: String = ""
    var quote: String = ""
    var percentChange: String = ""

    var incre: ChangeScope {
        if self.percentChange == "0" {
            return .equal
        } else if self.percentChange.contains("-") {
            return .less
        } else {
            return .greater
        }
    }

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< self.baseVolume <-- "base_volume"
        mapper <<< self.highestBid <-- "highest_bid"
        mapper <<< self.quoteVolume <-- "quote_volume"
        mapper <<< self.lowestAsk <-- "lowest_ask"
        mapper <<< self.percentChange <-- "percent_change"
        mapper <<<
            self.time <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss")
    }

    var hashValue: Int {
        let value = base.hashValue < quote.hashValue ? -1 : 1
        let valueStr = "\(base.hashValue)" + "+" + "\(quote.hashValue)"
        return value * valueStr.hashValue
    }

    init() {}
}
