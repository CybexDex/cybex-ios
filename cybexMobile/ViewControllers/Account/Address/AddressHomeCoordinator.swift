//
//  AddressHomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol AddressHomeCoordinatorProtocol {
    func openWithDrawAddressHomeViewController()
    func openTransferAddressHomeViewController()
}

protocol AddressHomeStateManagerProtocol {
    var state: AddressHomeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AddressHomeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class AddressHomeCoordinator: AccountRootCoordinator {
    lazy var creator = AddressHomePropertyActionCreate()

    var store = Store<AddressHomeState>(
        reducer: AddressHomeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
        
    override func register() {
        Broadcaster.register(AddressHomeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(AddressHomeStateManagerProtocol.self, observer: self)
    }
}

extension AddressHomeCoordinator: AddressHomeCoordinatorProtocol {
    func openWithDrawAddressHomeViewController() {
        let vc = R.storyboard.account.withdrawAddressHomeViewController()!
        let coor = WithdrawAddressHomeCoordinator(rootVC: self.rootVC)
        vc.coordinator = coor
        self.rootVC.pushViewController(vc, animated: true)
    }
    
    func openTransferAddressHomeViewController() {
        let vc = R.storyboard.account.transferAddressHomeViewController()!
        let coor = TransferAddressHomeCoordinator(rootVC: self.rootVC)
        vc.coordinator = coor
        self.rootVC.pushViewController(vc, animated: true)
    }
}

extension AddressHomeCoordinator: AddressHomeStateManagerProtocol {
    var state: AddressHomeState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AddressHomeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
