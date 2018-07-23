//
//  RechargeDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift


protocol RechargeDetailCoordinatorProtocol {
  func pop()
  func openWithdrawRecodeList()
}

protocol RechargeDetailStateManagerProtocol {
  var state: RechargeDetailState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<RechargeDetailState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  
  func fetchWithDrawInfoData(_ assetName:String)
  func verifyAddress(_ assetName:String,address:String,callback:@escaping (Bool)->())
  func getGatewayFee(_ assetId : String,amount:String,address:String)
  func login(_ password : String,callback:@escaping (Bool)->())
  func getObjects(assetId:String,amount:String,address:String,fee_id:String,fee_amount:String,callback:@escaping (Any)->())
  func fetchWithDrawMessage(callback:@escaping (String)->())
  func getFinalAmount(fee_id:String,amount:Decimal,available:Double) -> (Decimal,String)
}

class RechargeDetailCoordinator: AccountRootCoordinator {
  
  lazy var creator = RechargeDetailPropertyActionCreate()
  
  var store = Store<RechargeDetailState>(
    reducer: RechargeDetailReducer,
    state: nil,
    middleware:[TrackingMiddleware]
  )
}

extension RechargeDetailCoordinator: RechargeDetailCoordinatorProtocol {
  func pop(){
    self.rootVC.popViewController(animated: true)
  }
 
  func openWithdrawRecodeList() {
    if let vc = R.storyboard.recode.withdrawRecodeViewController() {
      vc.coordinator = WithdrawRecodeCoordinator(rootVC: self.rootVC)
      self.rootVC.pushViewController(vc, animated: true)
    }
  }
}

extension RechargeDetailCoordinator: RechargeDetailStateManagerProtocol {
  var state: RechargeDetailState {
    return store.state
  }
  
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<RechargeDetailState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
  
  func fetchWithDrawInfoData(_ assetName:String){
    async {
      let data = try? await(GraphQLManager.shared.getWithdrawInfo(assetName: assetName))
      main {
        if case let data?? = data {
          self.getWithdrawAccountInfo(data.gatewayAccount)
          self.store.dispatch(FetchWithdrawInfo(data : data))
        }
      }
    }
  }
  
  func getWithdrawAccountInfo(_ userID:String){
    let requeset = GetFullAccountsRequest(name: userID) { (response) in
      if let data = response as? FullAccount, let account = data.account {
        self.store.dispatch(FetchWithdrawMemokey(data:account.memo_key))
      }
    }
    WebsocketService.shared.send(request: requeset)
  }
  
  
  func getGatewayFee(_ assetId : String,amount:String,address:String){
      if let memo_key = self.state.property.memo_key.value{
        let name = app_data.assetInfo[assetId]?.symbol.filterJade
        if var amount = amount.toDouble(){
          let value = pow(10, (app_data.assetInfo[assetId]?.precision)!)
          amount = amount * Double(truncating: value as NSNumber)
          
          if let operationString = BitShareCoordinator.getTransterOperation(Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                                         to_user_id: Int32(getUserId((self.state.property.data.value?.gatewayAccount)!)),
                                                                         asset_id: Int32(getUserId(assetId)),
                                                                         amount: Int32(amount),
                                                                         fee_id: 0,
                                                                         fee_amount: 0,
                                                                         memo: GraphQLManager.shared.memo(name!, address: address),
                                                                         from_memo_key: UserManager.shared.account.value?.memo_key,
                                                                         to_memo_key: memo_key){
            
            calculateFee(operationString, focus_asset_id: assetId, operationID: .transfer) { (success, amount, fee_id) in
              
              let dictionary = ["asset_id":fee_id,"amount":amount.stringValue]
              self.store.dispatch(FetchGatewayFee(data:(Fee(JSON: dictionary)!,success:success)))
            }
          }
        }
    }
  }
  
  
  func verifyAddress(_ assetName:String,address:String,callback:@escaping (Bool)->()){
    async {
      let data = try? await(GraphQLManager.shared.verifyAddress(assetName: assetName, address: address))
      main {
        if case let data?? = data {
          callback(data.valid)
        }else{
          callback(false)
        }
      }
    }
  }
  
  func login(_ password : String,callback:@escaping (Bool)->()){
    if let name = UserManager.shared.name.value {
      UserManager.shared.unlock(name, password: password) { (isAuthory, account) in
        callback(isAuthory)
      }
    }
  }
  
  func getObjects(assetId:String,amount:String,address:String,fee_id:String,fee_amount:String,callback:@escaping (Any)->()){
    getChainId { (id) in
      if let memo_key = self.state.property.memo_key.value{
        let name = app_data.assetInfo[assetId]?.symbol.filterJade
        let requeset = GetObjectsRequest(ids: ["2.1.0"]) { (infos) in
          if let infos = infos as? (block_id:String,block_num:String){
            if var amount = amount.toDouble(){
              let value = pow(10, (app_data.assetInfo[assetId]?.precision)!)
              amount = amount * Double(truncating: value as NSNumber)
              
              let fee_amout = fee_amount.toDouble()! * Double(truncating: pow(10, (app_data.assetInfo[fee_id]?.precision)!) as NSNumber)
              
              let jsonstr =  BitShareCoordinator.getTransaction(Int32(infos.block_num)!,
                                                                block_id: infos.block_id,
                                                                expiration: Date().timeIntervalSince1970 + 10 * 3600,
                                                                chain_id: id,
                                                                from_user_id: Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                                to_user_id: Int32(getUserId((self.state.property.data.value?.gatewayAccount)!)),
                                                                asset_id: Int32(getUserId(assetId)),
                                                                receive_asset_id: Int32(getUserId(assetId)),
                                                                amount: Int32(amount),
                                                                fee_id: Int32(getUserId(fee_id)),
                                                                fee_amount: Int32(fee_amout),
                                                                memo: GraphQLManager.shared.memo(name!, address: address),
                                                                from_memo_key: UserManager.shared.account.value?.memo_key,
                                                                to_memo_key: memo_key)
              
              let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                main {
                  callback(data)
                }
              }, jsonstr: jsonstr!)
              WebsocketService.shared.send(request: withdrawRequest)
            }
          }
        }
        WebsocketService.shared.send(request: requeset)
      }
    }
  }
  
  func fetchWithDrawMessage(callback:@escaping (String)->()){
    async {
      let message = try? await(SimpleHTTPService.fetchWithdrawJsonInfo())
      main {
        if let message = message{
          if Localize.currentLanguage() == "en" {
            callback(message.enMsg)
          }else{
            callback(message.cnMsg)
          }
        }else{
          callback("")
        }
      }
    }
  }
  
  func getFinalAmount(fee_id:String,amount:Decimal,available:Double) -> (Decimal,String) {
    
    let allAmount = Decimal(available)
    var requestAmount : String = ""
    
    var finalAmount : Decimal = amount
    if fee_id != AssetConfiguration.CYB {
      if let gateway_fee = self.state.property.gatewayFee.value?.0,let gatewayFee = Decimal(string:gateway_fee.amount) {
        if allAmount < gatewayFee + amount {
          finalAmount = finalAmount - gatewayFee
          requestAmount = (amount - gatewayFee).stringValue
        }else{
          requestAmount = amount.stringValue
        }
      }
    }else{
      requestAmount = amount.stringValue
    }
    if let data = self.state.property.data.value {
      finalAmount = finalAmount - Decimal(data.fee)
    }
    return (finalAmount,requestAmount)
  }
  
}
