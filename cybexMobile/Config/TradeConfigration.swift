//
//  TradeConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import RxCocoa

class TradeConfiguration {
    static let shared = TradeConfiguration()

    static let defaultPrecision = """
    {
    "info": {
        "last_price": "5",
        "change": "5",
        "volume": "2"
    },
    "book": {
        "last_price": "5",
        "amount": "2",
        "total": "6"
    },
    "choose": {
        "last_price": "5",
        "volume": "2"
    },
    "form": {
        "min_trade_amount": "0.01",
        "amount_step": "0.01",
        "price_step": "0.00001",
        "min_order_value": "0.002",
        "total_step": "0.000001"
    }
    }
"""

    var tradePairPrecisions: BehaviorRelay<[Pair: PairPrecision]> = BehaviorRelay(value: [:]) //深度图精度

    private init() {

    }
    
    func getPairPrecisionWithPair(_ pair: Pair) -> PairPrecision {
        if let tradePairPrecision = self.tradePairPrecisions.value[Pair(base: pair.base, quote: pair.quote)] {
            return tradePairPrecision
        }

        var defaultPrecision = try! PairPrecision(TradeConfiguration.defaultPrecision)
        guard let baseInfo = appData.assetInfo[pair.base] else {
            return defaultPrecision
        }

        defaultPrecision.book.lastPrice = baseInfo.precision.string
        defaultPrecision.book.amount = AppConfiguration.amountPrecision.string
        defaultPrecision.book.total = "2"
        
        return defaultPrecision
    }
}

extension TradeConfiguration {
    func fetchPairPrecision() {
        AppService.request(target: .precisionSetting, success: { (json) in
            var precisions: [Pair: PairPrecision] = [:]

            for (base, value) in json.dictionaryValue {
                if let baseId = appData.assetNameToIds.value[base] {
                    for (quote, data) in value.dictionaryValue {
                        if let quoteId = appData.assetNameToIds.value[quote] {
                            let pair = Pair(base: baseId, quote: quoteId)
                            if let pairPrecision = try? PairPrecision(data: JSONSerialization.data(withJSONObject: data.object, options: [])) {
                                precisions[pair] = pairPrecision
                            }
                        }
                    }
                }
            }

            if precisions.count > 0 {
                self.tradePairPrecisions.accept(precisions)
            }
        }, error: { (_) in

        }) { (_) in
        }
    }
}

