//
//  WithdrawAddressCoordinator.swift
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

protocol WithdrawAddressCoordinatorProtocol {
    func openActionVC()
    
    func openAddWithdrawAddress()
}

protocol WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func refreshData(_ id:String?)
    
    func select(_ address:WithdrawAddress?)
    func copy()
    func confirmdelete()
    func delete()
}

class WithdrawAddressCoordinator: AccountRootCoordinator {
    lazy var creator = WithdrawAddressPropertyActionCreate()

    var store = Store<WithdrawAddressState>(
        reducer: WithdrawAddressReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
        
    override func register() {
        Broadcaster.register(WithdrawAddressCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAddressStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAddressCoordinator: WithdrawAddressCoordinatorProtocol {
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
    
    func openAddWithdrawAddress() {
        if let vc = R.storyboard.account.addAddressViewController() {
            vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
            Broadcaster.notify(WithdrawAddressHomeStateManagerProtocol.self) { (coor) in
                if let selectedModel = coor.state.property.selectedViewModel.value ,let firstModel = selectedModel.addressData.first{
                    vc.asset = firstModel.currency
                }
            }
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension WithdrawAddressCoordinator: WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
    func refreshData(_ id:String?) {
        if id == nil {
            Broadcaster.notify(WithdrawAddressHomeStateManagerProtocol.self) { (coor) in
                if let viewmodel = coor.state.property.selectedViewModel.value {
                    let addressData = viewmodel.addressData
                    self.store.dispatch(WithdrawAddressDataAction(data: addressData))
                }
            }
        }
    }
    
    func select(_ address:WithdrawAddress?) {
        self.store.dispatch(WithdrawAddressSelectDataAction(data: address))
    }
    
    func copy() {
        if let addressData = self.state.property.selectedAddress.value {
            UIPasteboard.general.string = addressData.address
            
            self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.copied())
        }
    }
    
    func confirmdelete() {
        self.rootVC.topViewController?.showConfirm(R.string.localizable.confirm(), attributes: nil)
    }
    
    func delete() {
        if let addressData = self.state.property.selectedAddress.value {
            AddressManager.shared.removeWithDrawAddress(addressData.id)
            
            Async.main {
                self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.deleted())
            }
        }
      
    }
}
