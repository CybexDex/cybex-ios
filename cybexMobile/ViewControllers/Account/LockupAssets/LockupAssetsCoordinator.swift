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
    
    func applyLockupAsset(_ sender: LockupAssteData)
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
    // 拉取数据的方法
    // 1 coordinator 是定义方法
    // 2 调用store去发送一个Action(creator创建一个Action)
    // 3
    func fetchLockupAssetsData(_ address: [String]) {
        let request = GetBalanceObjectsRequest(address: address) { response in
            if let data = response as? [LockUpAssetsMData] {
                self.store.dispatch(FetchedLockupAssetsData(data: data))
            }
        }
        CybexWebSocketService.shared.send(request: request)
    }
    
    func applyLockupAsset(_ sender: LockupAssteData) {
        
        getChainId { (id) in
            if let fromAccount = UserManager.shared.account.value, let keys = UserManager.shared.keys{
                let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                    if let infos = infos as? (block_id: String, block_num: String) {
                        if let balance = sender.balance, let assetInfo = appData.assetInfo[balance.assetID], let amount = balance.amount.toDecimal() {
                            let balanceAmount = amount
                            guard let fromAccount = UserManager.shared.account.value else {
                                return
                            }
                            
                            let jsonStr1 = BitShareCoordinator.getClaimedOperation(0, fee_amount: 0,
                                                                                   deposit_to_account_id: Int32(getUserId(fromAccount.id)),
                                                                                   claimed_id: Int32(getUserId(sender.id)),
                                                                                   claimed_asset_id: Int32(getUserId(balance.assetID)),
                                                                                   claimed_amount: Int32(balanceAmount.doubleValue),
                                                                                   to_account_pub_key: fromAccount.memoKey)
                            
                            let jsonstr = BitShareCoordinator.getClaimedSign(Int32(infos.block_num)!,
                                                                             block_id: infos.block_id,
                                                                             expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                             chain_id: id,
                                                                             fee_asset_id: 0,
                                                                             fee_amount: 0,
                                                                             deposit_to_account_id: Int32(getUserId(fromAccount.id)),
                                                                             claimed_id: Int32(getUserId(sender.id)),
                                                                             claimed_asset_id: Int32(getUserId(balance.assetID)),
                                                                             claimed_amount: Int32(balanceAmount.doubleValue),
                                                                             to_account_pub_key: fromAccount.memoKey)
                            
                            let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                                print("BroadcastTransactionRequest 转账请求 \(data)")
                            }, jsonstr: jsonstr!)
                            CybexWebSocketService.shared.send(request: withdrawRequest)
                        }
                    }
                }
                CybexWebSocketService.shared.send(request: requeset)
            }
        }
        
    }
}
