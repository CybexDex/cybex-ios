//
//  SettingCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol SettingCoordinatorProtocol {
  func openSettingDetail(type:settingPage)
  func openOpenedOrders()
  func openLockupAssets()
}

protocol SettingStateManagerProtocol {
    var state: SettingState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<SettingState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class SettingCoordinator: SettingRootCoordinator {
    
    lazy var creator = SettingPropertyActionCreate()
    
    var store = Store<SettingState>(
        reducer: SettingReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: SettingState {
        return store.state
    }
}

extension SettingCoordinator: SettingCoordinatorProtocol {
  func openSettingDetail(type:settingPage) {
    let vc = R.storyboard.main.settingDetailViewController()!
    vc.pageType = type
    let coordinator = SettingDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  func openOpenedOrders(){
    // 跳转到其他页面的时候
    // 1 创建跳转的页面
    // 2 创建跳转页面的路由coordinator。而且根路由要转换成当前VC
    // 3 路由赋值 然后跳转
    // 解释： 路由的赋值是相当于NavinationC的跳转路由栈的队列
    let vc = R.storyboard.openedOrder.openedOrdersViewController()!
    let coordinator = OpenedOrdersCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  // MARK: 锁定期资产
  func openLockupAssets(){
    let vc = R.storyboard.lockupAssets.lockupAssetsViewController()!
    let coordinator = LockupAssetsCoordinator(rootVC: self.rootVC)
    vc.coordinator  = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
  
}

extension SettingCoordinator: SettingStateManagerProtocol {
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<SettingState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
