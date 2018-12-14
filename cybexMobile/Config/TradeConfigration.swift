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

    var tradePairPrecisions: BehaviorRelay<[Pair: PairPrecision]> = BehaviorRelay(value: [:]) //深度图精度

    private init() {

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
                            let pairPrecision = PairPrecision(price: data["book"]["last_price"].intValue,
                                                              amount: data["book"]["amount"].intValue,
                                                              total: data["book"]["total"].intValue)
                            precisions[pair] = pairPrecision
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

