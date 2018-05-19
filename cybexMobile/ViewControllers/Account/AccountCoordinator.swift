//
//  AccountCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol AccountCoordinatorProtocol {
  func openOpenedOrders()
  func openLockupAssets()
  func openYourProtfolio()
  func openSetting()
}

protocol AccountStateManagerProtocol {
  var state: AccountState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<AccountState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
  
}

class AccountCoordinator: AccountRootCoordinator {
  
  lazy var creator = AccountPropertyActionCreate()
  
  var store = Store<AccountState>(
    reducer: AccountReducer,
    state: nil,
    middleware:[TrackingMiddleware]
  )
  
  var state: AccountState {
    return store.state
  }
}

extension AccountCoordinator: AccountCoordinatorProtocol {
  func openOpenedOrders(){
    // 跳转到其他页面的时候
    // 1 创建跳转的页面
    // 2 创建跳转页面的路由coordinator。而且根路由要转换成当前VC
    // 3 路由赋值 然后跳转
    // 解释： 路由的赋值是相当于NavinationC的跳转路由栈的队列
    let vc = R.storyboard.account.openedOrdersViewController()!
    let coordinator = OpenedOrdersCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  // MARK: 锁定期资产
  func openLockupAssets(){
    let vc = R.storyboard.account.lockupAssetsViewController()!
    let coordinator = LockupAssetsCoordinator(rootVC: self.rootVC)
    vc.coordinator  = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  // MARK: 可用资产
  func openYourProtfolio(){
    let vc = R.storyboard.account.yourProtfolioViewController()!
    let coordinator = YourPortfolioCoordinator(rootVC: self.rootVC)
    vc.coordinator  = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  // MARK: 设置
  func openSetting(){
    let vc = R.storyboard.main.settingViewController()!
    let coordinator = SettingCoordinator(rootVC: self.rootVC)
    vc.coordinator  = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}

extension AccountCoordinator: AccountStateManagerProtocol {
  
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<AccountState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
  
  
}
