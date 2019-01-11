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
    
    func checkConnectStatus() -> Bool
    func connect()
    func reconnect()
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

    func reconnect() {
        service.reconnect()
    }
    
    func connect() {
        service.connect()
        monitorService()
    }
    
    func checkConnectStatus() -> Bool {
        return service.checkNetworConnected()
    }

    func fetchOpenedOrder(_ pair: Pair) {
        service.messageCanSend.delegate(on: self) { (self, _) in
            self.fetchOpenedOrderRequest(pair)
        }
        if service.checkNetworConnected() {
            self.fetchOpenedOrderRequest(pair)
        }else {
            service.reconnect()
        }
    }
    func fetchOpenedOrderRequest(_ pair: Pair) {
        guard let userId = UserManager.shared.account.value?.id else { return }
        let request = GetLimitOrderStatus(response: { json in
            if let json = json as? [[String: Any]], let object = [LimitOrderStatus].deserialize(from: json) {
                self.store.dispatch(FetchOpenedOrderAction(data: object.compactMap({$0})))
            }
        }, status: LimitOrderStatusApi.getOpenedMarketLimitOrder(userId: userId, asset1Id: pair.quote, asset2Id: pair.base))
        self.service.send(request: request)
    }
    func fetchAllOpenedOrder() {
        service.messageCanSend.delegate(on: self) { (self, _) in
           self.fetchAllOpenedOrderRequest()
        }
        if service.checkNetworConnected() {
            self.fetchAllOpenedOrderRequest()
        }else {
            service.reconnect()
        }
    }
    
    func fetchAllOpenedOrderRequest() {
        guard let userId = UserManager.shared.account.value?.id else { return }
        let request = GetLimitOrderStatus(response: { (json) in
            if let orders = json as? [[String: Any]], let object = [LimitOrderStatus].deserialize(from: orders) {
                self.store.dispatch(FetchOpenedOrderAction(data: object.compactMap({$0})))
            }
        }, status: LimitOrderStatusApi.getOpenedLimitOrder(userId: userId))
        self.service.send(request: request)
    }

    func monitorService() {
        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }
            switch reachability.connection {
            case .wifi, .cellular:
                self.service.reconnect()
            case .none:
                self.service.disconnect()
                break
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { (note) in
            self.service.reconnect()
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

                                    let request = BroadcastTransactionRequest(response: { (data) in
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
