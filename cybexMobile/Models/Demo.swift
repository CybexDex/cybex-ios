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
    var base_volume: String = ""
    var latest: String = ""
    var time: Date?
    var highest_bid: String = ""
    var quote_volume: String = ""
    var lowest_ask: String = ""
    var quote: String = ""
    var percent_change: String = ""

    var incre: changeScope {
        if self.percent_change == "0" {
            return .equal
        } else if self.percent_change.contains("-") {
            return .less
        } else {
            return .greater
        }
    }

    mutating func mapping(mapper: HelpingMapper) {
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
