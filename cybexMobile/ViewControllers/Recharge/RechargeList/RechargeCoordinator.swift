//
//  RechargeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol RechargeCoordinatorProtocol {
  func openRechargeDetail(_ balance:Balance)
  func openWithDrawDetail()
}

protocol RechargeStateManagerProtocol {
    var state: RechargeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class RechargeCoordinator: AccountRootCoordinator {
    
    lazy var creator = RechargePropertyActionCreate()
    
    var store = Store<RechargeState>(
        reducer: RechargeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension RechargeCoordinator: RechargeCoordinatorProtocol {
  func openRechargeDetail(_ balance:Balance){
    let vc = R.storyboard.account.rechargeDetailViewController()!
    let coordinator = RechargeDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    vc.balance        = balance
    self.rootVC.pushViewController(vc, animated: true)
  }
  func openWithDrawDetail(){
    let vc = R.storyboard.account.withdrawDetailViewController()!
    let coordinator = WithdrawDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    
    self.rootVC.pushViewController(vc, animated: true)
  }
}

extension RechargeCoordinator: RechargeStateManagerProtocol {
    var state: RechargeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
