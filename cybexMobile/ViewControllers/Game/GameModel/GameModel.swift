//
//  GameModel.swift
//  cybexMobile
//
//  Created by DKM on 2018/12/7.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import JavaScriptCore
import SwiftyJSON
import cybex_ios_core_cpp
import PromiseKit

@objc protocol GameDelegate: JSExport {
    func login() -> String
    
    func redirected(_ url: String)
    
    func collect(_ params: Any, handle:@escaping (Bool)->())
}

class GameModel: NSObject, GameDelegate {
    
    var context: JSContext?
    
    func login() -> String {
        if !UserManager.shared.isLocked {
            let a = ["op": [
                "accountName": UserManager.shared.name.value!,
                "expiration": 1544083545044
                ],
                     "signer": "1f79bbb024c656ce1c5165d3abb4015f97a30a3d9542f707a0d175aa11c328c09c1f4c828762e3dbb14ad6882a6898ef9e2ba9ba27ad1cc1b790cdb0ac5f9345e1",
                     "balance": 10] as [String : Any]
            return JSON(a).rawString() ?? ""
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init("lockAccount"), object: nil)
        return ""
    }
    
    func redirected(_ url: String) {
        NotificationCenter.default.post(name: NSNotification.Name.init("openURL"), object: ["url": url])
    }
    
    
    func collect(_ params: Any, handle:@escaping (Bool)->()) {
        if let params = params as? [String: Any] {
            guard let toAccount = params["account"] as? String else {
                return
            }
            UserManager.shared.checkUserName(toAccount).done({[weak self] (exist) in
                main {
                    guard let self = self else { return }
                    if exist {
                        let requeset = GetFullAccountsRequest(name: toAccount) { (response) in
                            if let data = response as? FullAccount, let account = data.account {
                                getChainId { (id) in
                                    guard let amount = params["amount"] as? String else {
                                        return
                                    }
                                    guard let assetId = params["asset"] as? String else { return }
                                    guard let feeAmount = params["fee"] as? String else {
                                        return
                                    }
                                    guard let feeAssetId = params["fee_asset"] as? String else {
                                        return
                                    }
                                    
                                    let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                                        if let infos = infos as? (block_id: String, block_num: String) {
                                            if let assetInfo = appData.assetInfo[assetId], let feeInfo = appData.assetInfo[feeAssetId] {
                                                let value = pow(10, assetInfo.precision)
                                                let amount = amount.decimal() * value
                                                
                                                guard let fromAccount = UserManager.shared.account.value else {
                                                    return
                                                }
                                                
                                                let feeAmout = feeAmount.decimal() * pow(10, feeInfo.precision)
                                                
                                                let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                                                  block_id: infos.block_id,
                                                                                                  expiration: Date().timeIntervalSince1970 + AppConfiguration.TransactionExpiration,
                                                                                                  chain_id: id,
                                                                                                  from_user_id: Int32(getUserId(fromAccount.id)),
                                                                                                  to_user_id: Int32(getUserId(account.id)),
                                                                                                  asset_id: Int32(getUserId(assetId)),
                                                                                                  receive_asset_id: Int32(getUserId(assetId)),
                                                                                                  amount: amount.int64Value,
                                                                                                  fee_id: Int32(getUserId(feeAssetId)),
                                                                                                  fee_amount: feeAmout.int64Value,
                                                                                                  memo: "",
                                                                                                  from_memo_key: fromAccount.memoKey,
                                                                                                  to_memo_key: account.memoKey)
                                                
                                                let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                                                    main {
                                                        if String(describing: data) == "<null>" {
                                                            handle(true)
                                                        }
                                                        else {
                                                            handle(false)
                                                        }
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
                        CybexWebSocketService.shared.send(request: requeset)
                    }
                }
            }).cauterize()
            
        }
    }
}
