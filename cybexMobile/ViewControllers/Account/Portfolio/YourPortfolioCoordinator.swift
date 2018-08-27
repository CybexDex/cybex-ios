//
//  YourPortfolioCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol YourPortfolioCoordinatorProtocol {
  func pushToRechargeVC()
  func pushToWithdrawDepositVC()
  func pushToTransferVC(_ animate: Bool)
}

protocol YourPortfolioStateManagerProtocol {
    var state: YourPortfolioState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<YourPortfolioState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class YourPortfolioCoordinator: AccountRootCoordinator {
    
    lazy var creator = YourPortfolioPropertyActionCreate()
    
    var store = Store<YourPortfolioState>(
        reducer: YourPortfolioReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    override func register() {
        Broadcaster.register(YourPortfolioCoordinatorProtocol.self, observer: self)
        Broadcaster.register(YourPortfolioStateManagerProtocol.self, observer: self)
    }
}

extension YourPortfolioCoordinator: YourPortfolioCoordinatorProtocol {
  func pushToRechargeVC() {
    let vc = R.storyboard.account.rechargeViewController()!
    let coordinator = RechargeCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    vc.selectedIndex = .RECHARGE
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  func pushToWithdrawDepositVC() {
    let vc = R.storyboard.account.rechargeViewController()!
    let coordinator = RechargeCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    vc.selectedIndex = .WITHDRAW
    self.rootVC.pushViewController(vc, animated: true)
  }
  
  func pushToTransferVC(_ animate: Bool) {
    let transferVC = R.storyboard.recode.transferViewController()!
    let coordinator = TransferCoordinator(rootVC: self.rootVC)
    transferVC.coordinator = coordinator
    self.rootVC.pushViewController(transferVC, animated: animate)
  }
}

extension YourPortfolioCoordinator: YourPortfolioStateManagerProtocol {
    var state: YourPortfolioState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<YourPortfolioState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
