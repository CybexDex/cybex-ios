//
//  CybexConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import RxCocoa

class CybexConfiguration {
    static let shared = CybexConfiguration()

    static let portfolioOutPriceBaseOrderAsset = [
        AssetConfiguration.CybexAsset.CYB,
        AssetConfiguration.CybexAsset.USDT,
        AssetConfiguration.CybexAsset.ETH,
        AssetConfiguration.CybexAsset.BTC]

    var chainID: BehaviorRelay<String> = BehaviorRelay(value: "")

    static var TransactionExpiration: TimeInterval = 45
    static var TransactionTicketExpiration: TimeInterval = 60 * 30
    static var TransactionOrderExpiration: TimeInterval = 3600 * 24 * 365
    
    private init() {

    }
}

extension CybexConfiguration {
    func getChainId() {
        let requeset = GetChainIDRequest { (id) in
            if let id = id as? String {
                self.chainID.accept(id)
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }
}
