//
//  WithdrawDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol WithdrawDetailCoordinatorProtocol {
  func fetchDepositAddress(_ asset_name:String)
  func resetDepositAddress(_ asset_name:String)
  func fetchDepositMessage(callback:@escaping (String)->())
}

protocol WithdrawDetailStateManagerProtocol {
  var state: WithdrawDetailState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<WithdrawDetailState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
}

class WithdrawDetailCoordinator: AccountRootCoordinator {
  
  lazy var creator = WithdrawDetailPropertyActionCreate()
  
  var store = Store<WithdrawDetailState>(
    reducer: WithdrawDetailReducer,
    state: nil,
    middleware:[TrackingMiddleware]
  )
}

extension WithdrawDetailCoordinator: WithdrawDetailCoordinatorProtocol {
  func fetchDepositAddress(_ asset_name:String){
    if let name = UserManager.shared.name {
      async {
        let data = try? await(GraphQLManager.shared.getDepositAddress(accountName: name,assetName: asset_name))
        if case let data?? = data {
          main {
            self.store.dispatch(FetchAddressInfo(data: data))
          }
        }else{
          self.state.property.data.accept(nil)
        }
      }
    }
  }
  
  func resetDepositAddress(_ asset_name:String){
    if let name = UserManager.shared.name {
      async {
        let data = try? await(GraphQLManager.shared.updateDepositAddress(accountName: name, assetName: asset_name))
        if case let data?? = data {
          main {
            self.store.dispatch(FetchAddressInfo(data: data))
          }
        }else{
          self.state.property.data.accept(nil)
        }
      }
    }
  }
  
  func fetchDepositMessage(callback:@escaping (String)->()){
    async {
      let message = try? await(SimpleHTTPService.fetchDesipotInfoJsonInfo())
      main {
        if let message = message{
          callback(message)
        }else{
          callback("")
        }
      }
    }
  }
}

extension WithdrawDetailCoordinator: WithdrawDetailStateManagerProtocol {
  var state: WithdrawDetailState {
    return store.state
  }
  
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<WithdrawDetailState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
}
