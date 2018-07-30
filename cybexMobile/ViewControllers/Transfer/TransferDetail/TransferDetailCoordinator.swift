//
//  TransferDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol TransferDetailCoordinatorProtocol {
}

protocol TransferDetailStateManagerProtocol {
  var state: TransferDetailState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TransferDetailState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchAccoutInfoWithId(_ account_id : String,callback:@escaping(String)->())
}

class TransferDetailCoordinator: AccountRootCoordinator {
  
  lazy var creator = TransferDetailPropertyActionCreate()
  
  var store = Store<TransferDetailState>(
    reducer: TransferDetailReducer,
    state: nil,
    middleware:[TrackingMiddleware]
  )
}

extension TransferDetailCoordinator: TransferDetailCoordinatorProtocol {
  
}

extension TransferDetailCoordinator: TransferDetailStateManagerProtocol {
  var state: TransferDetailState {
    return store.state
  }
  
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<TransferDetailState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
  
  func fetchAccoutInfoWithId(_ account_id : String,callback:@escaping(String)->()) {
    let requeset = GetFullAccountsRequest(name: account_id) { (response) in
      if let data = response as? FullAccount, let account = data.account {
        callback(account.name)
      }
    }
    CybexWebSocketService.shared.send(request: requeset)
  }
}
