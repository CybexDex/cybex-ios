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
    func collect(_ account: String ,_ feeAsset: String, _ asset: String, _ fee: String, _ amount: String)
}

enum CallBackMethodName: String {
    case loginCallback
    case collectCallback
}

protocol GameModelCallBackDelegate {
    func lockAccount()
    func openURL(_ url: String)
}

class GameModel: NSObject, GameDelegate {
    
    var context: JSContext?
    var delegate: GameModelCallBackDelegate?
    var viewController: BaseViewController!
    
    static let codeArray = ["CYBEXGAMECENTER",
                            "GAMECENTERCYBEX",
                            "CENTERCYBEXGAME",
                            "GAMECYBEXCENTER",
                            "CYBEXCENTERGAME",
                            "CENTERGAMECYBEX",
                            "AMEERCYBEXGCENT",
                            "BEXGAMECYCENTER",
                            "TERCYBEXGAMECEN",
                            "EXCENTERMECYBGA"]
    
    func signerCallBack() -> String {
        guard let accountName = UserManager.shared.name.value, let balances = UserManager.shared.balances.value else { return "" }
        var usdtAmount: Decimal = 0
        var cybAmount: Decimal = 0
        if let balance = balances.filter({ return $0.assetType == AssetConfiguration.USDT}).first,
            let usdtInfo = appData.assetInfo[balance.assetType],
            let usdtDecimal = balance.balance.toDecimal() {
            usdtAmount = usdtDecimal / pow(10, usdtInfo.precision)
        }
        if let cybBalance = balances.filter({ return $0.assetType == AssetConfiguration.CYB }).first,
            let cybInfo = appData.assetInfo[cybBalance.assetType],
            let cybDecimal = cybBalance.balance.toDecimal() {
            cybAmount = cybDecimal / pow(10, cybInfo.precision)
        }
        let expiration = Date().timeIntervalSince1970 + 300
        let signer = BitShareCoordinator.getRecodeLoginOperation(accountName,
                                                                 asset: "",
                                                                 fundType: "",
                                                                 size: Int32(0),
                                                                 offset: Int32(0),
                                                                 expiration: Int32(expiration))!
        let result = ["op": [
            "accountName": accountName,
            "expiration": Int32(expiration)
            ],
                      "signer": JSON(parseJSON: signer)["signer"].stringValue,
                      "balance": usdtAmount.stringValue,
                      "fee_balance": cybAmount.stringValue] as [String : Any]
        return JSON(result).rawString() ?? ""
    }
    
    func loginCallBack() {
        self.context?.objectForKeyedSubscript(CallBackMethodName.loginCallback.rawValue)?.call(withArguments: [self.signerCallBack()])
    }
    
    func login() -> String {
        if !UserManager.shared.isLocked {
            return self.signerCallBack()
        }
        self.delegate?.lockAccount()
        return ""
    }
    
    func redirected(_ url: String) {
        self.delegate?.openURL(url)
    }
    
    func collect(_ account: String ,_ feeAsset: String, _ asset: String, _ fee: String, _ amount: String) {
        let toAccount = account
        UserManager.shared.checkUserName(toAccount).done({[weak self] (exist) in
            main {
                if exist {
                    let requeset = GetFullAccountsRequest(name: toAccount) { (response) in
                        if let data = response as? FullAccount, let account = data.account {
                            getChainId { (id) in
                                let assetId = asset
                                let feeAssetId = feeAsset
                                let requeset = GetObjectsRequest(ids: [ObjectID.dynamicGlobalPropertyObject.rawValue.snakeCased()]) { (infos) in
                                    if let infos = infos as? (block_id: String, block_num: String) {
                                        guard let fromAccount = UserManager.shared.account.value else { return }
                                        let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                                          block_id: infos.block_id,
                                                                                          expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                                          chain_id: id,
                                                                                          from_user_id: Int32(getUserId(fromAccount.id)),
                                                                                          to_user_id: Int32(getUserId(account.id)),
                                                                                          asset_id: Int32(getUserId(assetId)),
                                                                                          receive_asset_id: Int32(getUserId(assetId)),
                                                                                          amount: Int64(amount) ?? 0,
                                                                                          fee_id: Int32(getUserId(feeAssetId)),
                                                                                          fee_amount: Int64(fee) ?? 0,
                                                                                          memo: "game:deposit:" + fromAccount.name,
                                                                                          from_memo_key: fromAccount.memoKey,
                                                                                          to_memo_key: account.memoKey)
                                        
                                        let withdrawRequest = BroadcastTransactionRequest(response: { [weak self](data) in
                                            guard let `self` = self, let context = self.context else { return }
                                            main {
                                                context.objectForKeyedSubscript(CallBackMethodName.collectCallback.rawValue)?.call(withArguments: [String(describing: data) == "<null>" ? "0" : "1"])
                                            }
                                            }, jsonstr: jsonstr!)
                                        CybexWebSocketService.shared.send(request: withdrawRequest)
                                    }
                                }
                                CybexWebSocketService.shared.send(request: requeset)
                            }
                        }
                        else {
                            self?.context?.objectForKeyedSubscript(CallBackMethodName.collectCallback.rawValue)?.call(withArguments: ["2"])
                        }
                    }
                    CybexWebSocketService.shared.send(request: requeset)
                }
                else {
                    self?.context?.objectForKeyedSubscript(CallBackMethodName.collectCallback.rawValue)?.call(withArguments: ["2"])
                }
            }
        }).cauterize()
    }
}
