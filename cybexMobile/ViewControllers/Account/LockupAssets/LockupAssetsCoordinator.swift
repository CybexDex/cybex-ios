//
//  LockupAssetsCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol LockupAssetsCoordinatorProtocol {

}

protocol LockupAssetsStateManagerProtocol {
  var state: LockupAssetsState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<LockupAssetsState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  // 定义拉取数据的方法
  func fetchLockupAssetsData(_ address: [String])
}

class LockupAssetsCoordinator: AccountRootCoordinator {
  lazy var creator = LockupAssetsPropertyActionCreate()

  var store = Store<LockupAssetsState>(
    reducer: LockupAssetsReducer,
    state: nil,
    middleware: [TrackingMiddleware]
  )
}

extension LockupAssetsCoordinator: LockupAssetsCoordinatorProtocol {

}

extension LockupAssetsCoordinator: LockupAssetsStateManagerProtocol {
  var state: LockupAssetsState {
    return store.state
  }

  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<LockupAssetsState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }

  // 拉取数据的方法
  // 1 coordinator 是定义方法
  // 2 调用store去发送一个Action(creator创建一个Action)
  // 3 
  func fetchLockupAssetsData(_ address: [String]) {
    let request = getBalanceObjectsRequest(address: address) { response in
      if let data = response as? [LockUpAssetsMData] {
        self.store.dispatch(FetchedLockupAssetsData(data: data))
      }
    }
    CybexWebSocketService.shared.send(request: request)
  }
}
