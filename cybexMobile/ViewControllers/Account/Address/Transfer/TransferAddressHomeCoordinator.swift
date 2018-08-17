//
//  TransferAddressHomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol TransferAddressHomeCoordinatorProtocol {
    func openAddTransferAddress()
}

protocol TransferAddressHomeStateManagerProtocol {
    var state: TransferAddressHomeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferAddressHomeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class TransferAddressHomeCoordinator: AccountRootCoordinator {
    lazy var creator = TransferAddressHomePropertyActionCreate()

    var store = Store<TransferAddressHomeState>(
        reducer: TransferAddressHomeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
        
    override func register() {
        Broadcaster.register(TransferAddressHomeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(TransferAddressHomeStateManagerProtocol.self, observer: self)
    }
}

extension TransferAddressHomeCoordinator: TransferAddressHomeCoordinatorProtocol {
    func openAddTransferAddress() {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension TransferAddressHomeCoordinator: TransferAddressHomeStateManagerProtocol {
    var state: TransferAddressHomeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferAddressHomeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
