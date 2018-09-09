//
//  ETOCrowdCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ETOCrowdCoordinatorProtocol {
}

protocol ETOCrowdStateManagerProtocol {
    var state: ETOCrowdState { get }
    
    func switchPageState(_ state:PageState)
    
    func fetchData()
    func fetchUserRecord()
    func fetchFee()
    func joinCrowd(_ transferAmount:Double, callback: @escaping CommonAnyCallback)
}

class ETOCrowdCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOCrowdReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ETOCrowdState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(ETOCrowdCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOCrowdStateManagerProtocol.self, observer: self)
    }
}

extension ETOCrowdCoordinator: ETOCrowdCoordinatorProtocol {
    
}

extension ETOCrowdCoordinator: ETOCrowdStateManagerProtocol {
    func fetchFee() {
        guard let data = self.state.data.value else { return }
        
        var assetID = ""
        for (_, value) in app_data.assetInfo {
            if value.symbol.filterJade == data.base_token_name {
                assetID = value.id
                break
            }
        }
        
        guard !assetID.isEmpty, let operation = BitShareCoordinator.getTransterOperation(0, to_user_id: 0, asset_id: Int32(getUserId(assetID)), amount: 0, fee_id: 0, fee_amount: 0, memo: "", from_memo_key: "", to_memo_key: "") else { return }
        
        calculateFee(operation, focus_asset_id: assetID, operationID: .transfer) { (success, amount, fee_id) in
            let dictionary = ["asset_id":fee_id,"amount":amount.stringValue]
            
            if success {
                self.store.dispatch(SetFeeAction(fee: Fee(JSON: dictionary)!))
            }
            else {
                self.store.dispatch(SetFeeAction(fee: Fee(JSON: ["asset_id":assetID, "amount": "0"])!))
            }
        }
    }
    
    func joinCrowd(_ transferAmount:Double, callback: @escaping CommonAnyCallback) {
        guard let fee = self.state.fee.value, let data = self.state.data.value else { return }
        
        var assetID = ""
        for (_, value) in app_data.assetInfo {
            if value.symbol.filterJade == data.base_token_name {
                assetID = value.id
                break
            }
        }
        
        guard !assetID.isEmpty, let uid = UserManager.shared.account.value?.id, let info = app_data.assetInfo[assetID], let fee_amount = fee.amount.toDouble(), let feeInfo = app_data.assetInfo[fee.asset_id] else { return }
        let value = pow(10, info.precision)
        let amount = transferAmount * Double(truncating: value as NSNumber)
        
        let fee_amout = fee_amount * Double(truncating: pow(10, feeInfo.precision) as NSNumber)

        getChainId { (id) in
            let requeset = GetObjectsRequest(ids: [objectID.dynamic_global_property_object.rawValue]) { (infos) in
                if let infos = infos as? (block_id:String,block_num:String) {
                    let accountRequeset = GetFullAccountsRequest(name: data.receive_address) { (response) in
                        if let response = response as? FullAccount, let account = response.account {
                            let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                              block_id: infos.block_id,
                                                                              expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                              chain_id: id,
                                                                              from_user_id: Int32(getUserId(uid)),
                                                                              to_user_id: Int32(getUserId(account.id)),
                                                                              asset_id: Int32(getUserId(assetID)),
                                                                              receive_asset_id: Int32(getUserId(assetID)),
                                                                              amount: Int64(amount),
                                                                              fee_id: Int32(getUserId(fee.asset_id)),
                                                                              fee_amount: Int64(fee_amout),
                                                                              memo: "",
                                                                              from_memo_key: "",
                                                                              to_memo_key: "")
                            guard let ope = jsonstr else {
                                main {
                                    callback("")
                                }
                                return
                            }
                            let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                                main {
                                    callback(data)
                                }
                            }, jsonstr: ope)
                            CybexWebSocketService.shared.send(request: withdrawRequest)
                        }
                    }
                        
                    CybexWebSocketService.shared.send(request: accountRequeset)
                }
            }
            CybexWebSocketService.shared.send(request: requeset)
        }
    }
    
    func fetchData() {
        Broadcaster.notify(ETODetailStateManagerProtocol.self) {(coor) in
            if let data = coor.state.data.value?.projectModel {
                self.store.dispatch(SetProjectDetailAction(data: data))
            }
        }
    }
    
    func fetchUserRecord() {
        guard let name = UserManager.shared.name.value, let data = self.state.data.value else { return }

        ETOMGService.request(target: .refreshUserState(name: name, pid: data.id), success: { (json) in
            if let model = ETOUserModel.deserialize(from: json.dictionaryObject) {
                self.store.dispatch(fetchCurrentTokenCountAction(userModel: model))
            }
            
        }, error: { (error) in
            
        }) { (error) in
            
        }
    }
    
    func switchPageState(_ state:PageState) {
        self.store.dispatch(PageStateAction(state: state))
    }
}
