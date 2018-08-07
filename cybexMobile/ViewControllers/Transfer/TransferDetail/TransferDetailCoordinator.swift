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
}
