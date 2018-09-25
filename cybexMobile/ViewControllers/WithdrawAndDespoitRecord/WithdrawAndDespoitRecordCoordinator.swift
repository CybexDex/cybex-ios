//
//  WithdrawAndDespoitRecordCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import Async

protocol WithdrawAndDespoitRecordCoordinatorProtocol {
}

protocol WithdrawAndDespoitRecordStateManagerProtocol {
    var state: WithdrawAndDespoitRecordState { get }
    
    func switchPageState(_ state:PageState)
    
    func setupChildrenVC(_ segue: UIStoryboardSegue)
}

class WithdrawAndDespoitRecordCoordinator: AccountRootCoordinator {
    var store = Store(
        reducer: WithdrawAndDespoitRecordReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: WithdrawAndDespoitRecordState {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(WithdrawAndDespoitRecordCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAndDespoitRecordStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAndDespoitRecordCoordinator: WithdrawAndDespoitRecordCoordinatorProtocol {
    
}

extension WithdrawAndDespoitRecordCoordinator: WithdrawAndDespoitRecordStateManagerProtocol {
    func switchPageState(_ state:PageState) {
        Async.main {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
    
    func setupChildrenVC(_ segue: UIStoryboardSegue) {
        if let segueInfo = R.segue.withdrawAndDespoitRecordViewController.withdrawAndDespoitRecordViewController(segue: segue) {
            segueInfo.destination.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
        }
    }
}
