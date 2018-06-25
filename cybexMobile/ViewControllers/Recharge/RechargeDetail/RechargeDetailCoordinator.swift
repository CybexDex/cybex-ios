//
//  RechargeDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol RechargeDetailCoordinatorProtocol {
}

protocol RechargeDetailStateManagerProtocol {
  var state: RechargeDetailState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<RechargeDetailState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchWithDrawInfoData(_ assetName:String)
  func verifyAddress(_ assetName:String,address:String)->Bool
  func getGatewayFee(_ assetId : String,amount:String,feeAssetID:String,address:String)
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
    BitShareCoordinator.resetDefaultPublicKey(UserManager.shared.keys?.memo_key?.public_key)
    let requeset = GetFullAccountsRequest(name: userID) { (response) in
      if let data = response as? FullAccount, let account = data.account {
        self.state.property.memo_key.accept(account.memo_key)
      }
    }
    WebsocketService.shared.send(request: requeset)
  }
  
  
  func getGatewayFee(_ assetId : String,amount:String,feeAssetID:String,address:String){
    if let memo_key = self.state.property.memo_key.value{
      
      BitShareCoordinator.getUserKeys("cybex-test", password: "cybextest123456")
      let name = app_data.assetInfo[assetId]?.symbol.filterJade
      let operationString = BitShareCoordinator.getTransterOperation(Int32(getUserId((UserManager.shared.account.value?.id)!)),
                                                      to_user_id: Int32(getUserId((self.state.property.data.value?.gatewayAccount)!)),
                                                      asset_id: Int32(getUserId(assetId)),
                                                      amount: Int32(amount)!,
                                                      fee_id: 0,
                                                      fee_amount: 0,
                                                      memo: GraphQLManager.shared.memo(name!, address: address),
                                                      from_memo_key: UserManager.shared.account.value?.memo_key,
                                                      to_memo_key: memo_key)
      let request = GetRequiredFees(response: { (infos) in
        if let infos = infos as? [Fee]{
          self.state.property.gatewayFee.accept(infos.first)
        }
        print("GetRequiredFees \(infos)")
      }, operationStr: operationString!, assetID: feeAssetID)
      WebsocketService.shared.send(request: request)
    }
  }
  
  
  func verifyAddress(_ assetName:String,address:String)->Bool{
    let data = try? await(GraphQLManager.shared.verifyAddress(assetName: assetName, address: address))
    if case let data?? = data {
      return data.valid
    }else{
      return false
    }
  }
  
}
