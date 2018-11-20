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

  // 定义拉取数据的方法
  func fetchLockupAssetsData(_ address: [String])
}

class LockupAssetsCoordinator: AccountRootCoordinator {
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
}
