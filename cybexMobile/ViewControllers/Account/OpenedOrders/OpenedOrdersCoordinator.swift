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
import SwiftyJSON
import Reachability

// 跳转
protocol OpenedOrdersCoordinatorProtocol {
}
// 业务处理
protocol OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState { get }

    func disconnect()
    func cancelOrder(_ orderID: String, feeId: String, callback: @escaping (_ success: Bool) -> Void)
    func fetchOpenedOrder(_ pair: Pair)
    func fetchAllOpenedOrder()
}

class OpenedOrdersCoordinator: NavCoordinator {
    var store = Store<OpenedOrdersState>(
        reducer: gOpenedOrdersReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    let service = OCOWebSocketService()

}

extension OpenedOrdersCoordinator: OpenedOrdersCoordinatorProtocol {

}

extension OpenedOrdersCoordinator: OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState {
        return store.state
    }

    func connect() {
        service.connect()
    }

    func fetchOpenedOrder(_ pair: Pair) {
        guard let userId = UserManager.shared.account.value?.id else { return }
        service.messageCanSend.delegate(on: self) { (self, _) in
            let request = GetLimitOrderStatus(response: { json in
                if let json = json as? JSON, let object = [LimitOrderStatus].deserialize(from: json.rawString()) {
                    
                    print("GetLimitOrderStatus \(object.compactMap({ $0 }))")
                }
            }, status: LimitOrderStatusApi.getOpenedMarketLimitOrder(userId: userId, asset1Id: pair.quote, asset2Id: pair.base))
            self.service.send(request: request)
        }
        monitorService()
        service.connect()
    }

    func fetchAllOpenedOrder() {
        guard let userId = UserManager.shared.account.value?.id else { return }

        let limit = 100

        service.messageCanSend.delegate(on: self) { (self, _) in
            let request = GetLimitOrderStatus(response: { json in
                if let json = json as? JSON {
                    let maxId = json["result"].stringValue

                    let request = GetLimitOrderStatus(response: { json in
                        print(json)
                    }, status: LimitOrderStatusApi.getLimitOrder(userId: userId, lessThanOrderId: maxId, limit: limit))
                    self.service.send(request: request)
                }
            }, status: LimitOrderStatusApi.getMaxLimitOrderIdByTime(date: Date()))
            self.service.send(request: request)
        }
        monitorService()
        service.connect()
    }

    func monitorService() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }

            switch reachability.connection {
            case .wifi, .cellular:
                if self.rootVC.topViewController is OpenedOrdersViewController {
                    self.service.reconnect()
                }
            case .none:
                self.service.disconnect()
                break
            }

        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            if self.rootVC.topViewController is OpenedOrdersViewController {
                self.service.reconnect()
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { (note) in
            self.service.disconnect()
        }
    }

    func disconnect() {
        service.disconnect()
    }

    func cancelOrder(_ orderID: String, feeId: String, callback: @escaping (_ success: Bool) -> Void) {
        guard let userid = UserManager.shared.account.value?.id else { return }
        guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0) else { return }

        CybexChainHelper.calculateFee(operation,
                                      operationID: .limitOrderCancel, focusAssetId: feeId) { (success, amount, assetID) in
                        print("手续费是否成功: \(success)")
                        if success {
                            CybexChainHelper.blockchainParams { (blockchainParams) in
                                guard let asset = appData.assetInfo[assetID] else {return}
                                if let jsonStr = BitShareCoordinator.cancelLimitOrder(
                                    blockchainParams.block_num.int32,
                                    block_id: blockchainParams.block_id,
                                    expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration,
                                    chain_id: CybexConfiguration.shared.chainID.value,
                                    user_id: userid.getSuffixID,
                                    order_id: orderID.getSuffixID,
                                    fee_id: assetID.getSuffixID,
                                    fee_amount: (amount * pow(10, asset.precision)).int64Value) {

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
