//
//  TradeConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

class TradeConfiguration {
    static let shared = TradeConfiguration()

    private init() {

    }
}

extension TradeConfiguration {
    func fetchPairPrecision() {
        AppService.request(target: .precisionSetting, success: { (json) in
            for (key, value) in json.dictionaryValue {

            }
        }, error: { (_) in

        }) { (_) in

        }
    }
}

