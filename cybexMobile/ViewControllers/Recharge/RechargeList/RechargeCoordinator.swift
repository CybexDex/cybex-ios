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
  func openRechargeDetail(_ balance:Balance,isWithdraw:Bool)
  func openWithDrawDetail(_ id:String)
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
  func openRechargeDetail(_ balance:Balance,isWithdraw:Bool){
    let vc = R.storyboard.account.rechargeDetailViewController()!
    let coordinator   = RechargeDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator    = coordinator
    vc.balance        = balance
    vc.isWithdraw     = isWithdraw
    self.rootVC.pushViewController(vc, animated: true)
  }
  func openWithDrawDetail(_ id:String){
    let vc = R.storyboard.account.withdrawDetailViewController()!
    let coordinator = WithdrawDetailCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    vc.withdrawId     = id
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
    async {
      SimpleHTTPService.fetchIdsInfo(AppConfiguration.WITHDRAW).done { (ids) in
        self.store.dispatch(FecthWithdrawIds(data: ids))
        }.cauterize()
    }
  }
  func fetchDepositIdsInfo(){
    async {
      SimpleHTTPService.fetchIdsInfo(AppConfiguration.DEPOSIT).done { (ids) in
        self.store.dispatch(FecthDepositIds(data: ids))
        }.cauterize()
    }
  }
    
}
