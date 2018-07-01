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
  func openRechargeDetail(_ trade:Trade)
  func openWithDrawDetail(_ trade:Trade)
}

protocol RechargeStateManagerProtocol {
    var state: RechargeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<RechargeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func fetchWithdrawIdsInfo()
  func fetchDepositIdsInfo()
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
  func openRechargeDetail(_ trade:Trade){
    let vc = R.storyboard.account.rechargeDetailViewController()!
    let coordinator   = RechargeDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator    = coordinator
    vc.trade          = trade
    vc.isWithdraw     = trade.enable
    self.rootVC.pushViewController(vc, animated: true)
  }
  func openWithDrawDetail(_ trade:Trade){
    let vc = R.storyboard.account.withdrawDetailViewController()!
    let coordinator = WithdrawDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    vc.trade     = trade
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
  func fetchWithdrawIdsInfo(){
    SimpleHTTPService.fetchWithdrawIdsInfo().done { (ids) in
        self.store.dispatch(FecthWithdrawIds(data: ids))
      }.cauterize()
  }
  func fetchDepositIdsInfo(){
    SimpleHTTPService.fetchDesipotInfo().done { (ids) in
        self.store.dispatch(FecthDepositIds(data: ids))
      }.cauterize()
  }
    
}
