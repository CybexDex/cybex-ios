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
import Dollar

protocol TransferAddressHomeCoordinatorProtocol {
    func openAddTransferAddress()
    func openActionVC(_ dismissCallback:CommonCallback?)
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
            vc.address_type = .transfer
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
    
    func openActionVC(_ dismissCallback:CommonCallback?) {
        let actionController = PeriscopeActionController()
        actionController.tapMaskCallback = dismissCallback
        
        actionController.addAction(Action(R.string.localizable.copy.key.localized(), style: .destructive, handler: {[weak self] action in
            guard let `self` = self else {return}
            self.copy()
            dismissCallback?()
        }))
        
        actionController.addAction(Action(R.string.localizable.delete.key.localized(), style: .destructive, handler: {[weak self] action in
            guard let `self` = self else {return}
            self.confirmdelete()
            dismissCallback?()
        }))
        
        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action(R.string.localizable.alert_cancle.key.localized(), style: .cancel, handler: {[weak self] action in
            guard let `self` = self else {return}
            
            self.select(nil)
            dismissCallback?()
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
        let list = AddressManager.shared.getTransferAddressList()
        
        let names = list.map { (info) -> AddressName in
            return AddressName(name: info.name)
        }
        
        let sortedNames = sortNameBasedonAddress(names)
     
        let data = list.sorted { (front, last) -> Bool in
             return sortedNames.index(of: front.name)! <= sortedNames.index(of: last.name)!
        }
        self.store.dispatch(TransferAddressHomeDataAction(data: data))
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
            self.rootVC.topViewController?.showConfirm(R.string.localizable.confirm(), attributes: confirmDeleteTransferAddress(addressData), setup: { (labels) in
                for label in labels {
                    label.content.numberOfLines = 1
                    label.content.lineBreakMode = .byTruncatingMiddle
                }
            })
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
