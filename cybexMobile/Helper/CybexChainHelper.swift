//
//  CybexChainHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import SwiftTheme
import SwiftyJSON
import SwiftyUserDefaults
import cybex_ios_core_cpp

typealias TransactionBaseType = (block_id: String, block_num: String)
typealias FeeResult = (success: Bool, amount: Decimal, assetID: String)

class CybexChainHelper {
    class func blockchainParams(callback: @escaping (TransactionBaseType) -> Void) {
        let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
            if let infos = infos as? TransactionBaseType {
                callback(infos)
            }
        }
        CybexWebSocketService.shared.send(request: requeset)
    }


    /// 计算手续费 优先使用cyb 没有则使用focusAssetId
    ///
    /// - Parameters:
    ///   - operation: transaction operation string
    ///   - operationID: operate id
    ///   - focusAssetId: alternative asset id
    ///   - completion:
    class func calculateFee(_ operation: String,
                            operationID: ChainTypesOperations = .limitOrderCreate,
                            focusAssetId: String,
                            completion: @escaping (FeeResult) -> Void) {
        let cybBalance = UserHelper.getBalanceFromAssetID(AssetConfiguration.CybexAsset.CYB.id)
        let focusBalance = UserHelper.getBalanceFromAssetID(focusAssetId)

        if cybBalance == 0 {
            if focusBalance == 0 {
                completion((success: false, amount: 0, assetID: ""))
                return
            }
            else {
                calculateFeeOfAsset(focusAssetId, operation: operation, operationID: operationID) { (result) in
                    let amount = AssetHelper.getRealAmount(focusAssetId, amount: result.string)
                    if focusBalance >= result {
                        completion((success: true, amount: amount, assetID: focusAssetId))
                    } else {
                        completion((success: false, amount: amount, assetID: focusAssetId))
                    }
                }
            }
        }
        else {
            calculateFeeOfAsset(AssetConfiguration.CybexAsset.CYB.id, operation: operation, operationID: operationID) { (result) in
                let amount = AssetHelper.getRealAmount(AssetConfiguration.CybexAsset.CYB.id, amount: result.string)

                if cybBalance >= result {
                    completion((success: true, amount: amount, assetID: AssetConfiguration.CybexAsset.CYB.id))
                } else if focusBalance == 0 {
                    completion((success: false, amount: amount, assetID: AssetConfiguration.CybexAsset.CYB.id))
                } else {
                    calculateFeeOfAsset(focusAssetId, operation: operation, operationID: operationID) { (result) in
                        let amount = AssetHelper.getRealAmount(focusAssetId, amount: result.string)

                        if focusBalance >= result {
                            completion((success: true, amount: amount, assetID: focusAssetId))
                        } else {
                            completion((success: false, amount: amount, assetID: focusAssetId))
                        }
                    }
                }
            }
        }

    }

    class func calculateFeeOfAsset(_ assetID: String,
                               operation: String,
                               operationID: ChainTypesOperations = .limitOrderCreate,
                               completion: @escaping (Decimal) -> Void) {
        let request = GetRequiredFees(response: { (data) in
            guard let fees = data as? [Fee], let amount = fees.first?.amount.decimal() else {
                completion(0)
                return
            }
            completion(amount)

        }, operationStr: operation, assetID: assetID, operationID: operationID)

        CybexWebSocketService.shared.send(request: request)
    }
}
