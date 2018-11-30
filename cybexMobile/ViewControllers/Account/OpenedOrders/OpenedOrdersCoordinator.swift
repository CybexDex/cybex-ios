//
//  OpenedOrdersCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//  路由文件。  跳转/业务处理

import UIKit
import ReSwift
import cybex_ios_core_cpp

// 跳转
protocol OpenedOrdersCoordinatorProtocol {
}
// 业务处理
protocol OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState { get }

    func cancelOrder(_ orderID: String, feeId: String, callback: @escaping (_ success: Bool) -> Void)
}

class OpenedOrdersCoordinator: NavCoordinator {
    var store = Store<OpenedOrdersState>(
        reducer: gOpenedOrdersReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension OpenedOrdersCoordinator: OpenedOrdersCoordinatorProtocol {

}

extension OpenedOrdersCoordinator: OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState {
        return store.state
    }

    func cancelOrder(_ orderID: String, feeId: String, callback: @escaping (_ success: Bool) -> Void) {
        guard let userid = UserManager.shared.account.value?.id else { return }
        guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0) else { return }

        calculateFee(operation,
                     focusAssetId: feeId,
                     operationID: .limitOrderCancel, filterRepeat: false) { (success, amount, assetID) in
                        print("手续费是否成功: \(success)")
                        if success {
                            blockchainParams { (blockchainParams) in
                                guard let asset = appData.assetInfo[assetID] else {return}
                                if let jsonStr = BitShareCoordinator.cancelLimitOrder(
                                    blockchainParams.block_num,
                                    block_id: blockchainParams.block_id,
                                    expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                    chain_id: blockchainParams.chain_id,
                                    user_id: userid.getID,
                                    order_id: orderID.getID,
                                    fee_id: assetID.getID,
                                    fee_amount: Int64(amount.doubleValue * pow(10, asset.precision.double))) {

                                    print("blockchainParams:\(jsonStr)")

                                    let request = BroadcastTransactionRequest(response: { (data) in
                                        print("提交信息---\(data)")

                                        if String(describing: data) == "<null>" {
                                            callback(true)
                                        } else {
                                            callback(false)
                                        }
                                    }, jsonstr: jsonStr)
                                    CybexWebSocketService.shared.send(request: request)
                                }
                            }
                        } else {
                            callback(false)
                        }
        }
    }
}
