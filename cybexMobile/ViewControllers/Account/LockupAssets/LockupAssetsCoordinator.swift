//
//  LockupAssetsCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import cybex_ios_core_cpp

protocol LockupAssetsCoordinatorProtocol {
    
}

protocol LockupAssetsStateManagerProtocol {
    var state: LockupAssetsState { get }
    
    // 定义拉取数据的方法
    func fetchLockupAssetsData(_ address: [String])
    
    func applyLockupAsset(_ sender: LockupAssteData, callback: @escaping (Bool)->())
}

class LockupAssetsCoordinator: NavCoordinator {
    var store = Store<LockupAssetsState>(
        reducer: gLockupAssetsReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension LockupAssetsCoordinator: LockupAssetsCoordinatorProtocol {
    
}

extension LockupAssetsCoordinator: LockupAssetsStateManagerProtocol {
    var state: LockupAssetsState {
        return store.state
    }
    
    func fetchLockupAssetsData(_ address: [String]) {
        let request = GetBalanceObjectsRequest(address: address) { response in
            if let data = response as? [LockUpAssetsMData] {
                self.store.dispatch(FetchedLockupAssetsData(data: data))
            }
        }
        CybexWebSocketService.shared.send(request: request)
    }
    
    func applyLockupAsset(_ sender: LockupAssteData, callback: @escaping (Bool)->()) {
        if let fromAccount = UserManager.shared.account.value{
            let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                if let infos = infos as? (block_id: String, block_num: String) {
                    if let balance = sender.balance {
                        let amount = balance.amount.decimal()
                        let balanceAmount = amount
                        guard let fromAccount = UserManager.shared.account.value else {
                            return
                        }

                        let jsonstr = BitShareCoordinator.getClaimedSign(infos.block_num.int32,
                                                                         block_id: infos.block_id,
                                                                         expiration: Date().timeIntervalSince1970 + CybexConfiguration.TransactionExpiration,
                                                                         chain_id: CybexConfiguration.shared.chainID.value,
                                                                         fee_asset_id: 0,
                                                                         fee_amount: 0,
                                                                         deposit_to_account_id: fromAccount.id.getSuffixID,
                                                                         claimed_id: sender.id.getSuffixID,
                                                                         claimed_asset_id: balance.assetID.getSuffixID,
                                                                         claimed_amount: balanceAmount.int64Value,
                                                                         claimed_own: sender.owner)

                        let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                            if String(describing: data) == "<null>"{
                                callback(true)
                            } else {
                                callback(false)
                            }
                        }, jsonstr: jsonstr!)
                        CybexWebSocketService.shared.send(request: withdrawRequest)
                    }
                }
            }
            CybexWebSocketService.shared.send(request: requeset)
        }

    }
}
