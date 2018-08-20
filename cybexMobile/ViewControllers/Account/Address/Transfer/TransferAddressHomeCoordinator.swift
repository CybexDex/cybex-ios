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
import XLActionController
import Async

protocol TransferAddressHomeCoordinatorProtocol {
    func openAddTransferAddress()
    func openActionVC()
}

protocol TransferAddressHomeStateManagerProtocol {
    var state: TransferAddressHomeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferAddressHomeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func refreshData()
    
    func select(_ address:TransferAddress?)
    func copy()
    func confirmdelete()
    func delete()
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
    
    func openActionVC() {
        let actionController = PeriscopeActionController()
        
        actionController.addAction(Action(R.string.localizable.copy.key.localized(), style: .destructive, handler: {[weak self] action in
            guard let `self` = self else {return}
            self.copy()
        }))
        
        actionController.addAction(Action(R.string.localizable.delete.key.localized(), style: .destructive, handler: {[weak self] action in
            guard let `self` = self else {return}
            self.confirmdelete()
        }))
        
        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action(R.string.localizable.alert_cancle.key.localized(), style: .cancel, handler: {[weak self] action in
            guard let `self` = self else {return}
            
            self.select(nil)
        }))
        
        self.rootVC.topViewController?.present(actionController, animated: true, completion: nil)
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
    
    func refreshData() {
        let list = AddressManager.shared.getTransferAddressList().sorted(by: \.name, ascending: false)
        self.store.dispatch(TransferAddressHomeDataAction(data: list))
    }
    
    func select(_ address:TransferAddress?) {
        self.store.dispatch(TransferAddressSelectDataAction(data: address))
    }
    
    func copy() {
        if let addressData = self.state.property.selectedAddress.value {
            UIPasteboard.general.string = addressData.address
            
            self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.copied())
        }
    }
    
    func confirmdelete() {
        if let addressData = self.state.property.selectedAddress.value {
            self.rootVC.topViewController?.showConfirm(R.string.localizable.confirm(), attributes: [confirmDeleteTransferAddress(addressData)])
        }
    }
    
    func delete() {
        if let addressData = self.state.property.selectedAddress.value {
            AddressManager.shared.removeTransferAddress(addressData.id)
            
            Async.main {
                self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.deleted())
            }
        }
        
    }
}
