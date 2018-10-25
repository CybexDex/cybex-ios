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
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<OpenedOrdersState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

  func cancelOrder(_ orderID: String, fee_id: String, callback: @escaping (_ success: Bool) -> Void)
}

class OpenedOrdersCoordinator: AccountRootCoordinator {

    lazy var creator = OpenedOrdersPropertyActionCreate()

    var store = Store<OpenedOrdersState>(
        reducer: OpenedOrdersReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )
}

extension OpenedOrdersCoordinator: OpenedOrdersCoordinatorProtocol {

}

extension OpenedOrdersCoordinator: OpenedOrdersStateManagerProtocol {
    var state: OpenedOrdersState {
        return store.state
    }

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<OpenedOrdersState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

  func cancelOrder(_ orderID: String, fee_id: String, callback: @escaping (_ success: Bool) -> Void) {
    guard let userid = UserManager.shared.account.value?.id else { return }
    guard let operation = BitShareCoordinator.cancelLimitOrderOperation(0, user_id: 0, fee_id: 0, fee_amount: 0) else { return }

    calculateFee(operation, focus_asset_id: fee_id, operationID: .limit_order_cancel, filterRepeat: false) { (success, amount, assetID) in
      if success {
        blockchainParams { (blockchain_params) in
          guard let asset = appData.assetInfo[assetID] else {return}
            if let jsonStr = BitShareCoordinator.cancelLimitOrder(blockchain_params.block_num, block_id: blockchain_params.block_id, expiration: Date().timeIntervalSince1970 + 10 * 3600, chain_id: blockchain_params.chain_id, user_id: userid.getID, order_id: orderID.getID, fee_id: assetID.getID, fee_amount: Int64(amount.doubleValue * pow(10, asset.precision.double))) {
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
