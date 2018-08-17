//
//  AddAddressCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

enum address_type : String {
    case withdraw
    case transfer
}

protocol AddAddressCoordinatorProtocol {
}

protocol AddAddressStateManagerProtocol {
    var state: AddAddressState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AddAddressState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    
    func verityAddress(_ address : String, type:address_type)
    
    func setAsset(_ asset : String)

    func verityNote(_ success : Bool)

    func addAddress(_ type : address_type)
}

class AddAddressCoordinator: AccountRootCoordinator {
    
    lazy var creator = AddAddressPropertyActionCreate()
    
    var store = Store<AddAddressState>(
        reducer: AddAddressReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension AddAddressCoordinator: AddAddressCoordinatorProtocol {
    
}

extension AddAddressCoordinator: AddAddressStateManagerProtocol {
    var state: AddAddressState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AddAddressState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
    func verityAddress(_ address: String, type: address_type) {
        switch type {
        case .transfer:
            
            UserManager.shared.checkUserName(address).done({ (exist) in
                main {
                    self.store.dispatch(VerificationAddressAction(success:!exist))
                }
            }).cauterize()
            
        case .withdraw:
            
            Broadcaster.notify(RechargeDetailCoordinator.self) { (rechargeCoordinator) in
                rechargeCoordinator.verifyAddress(self.state.property.asset.value, address: address, callback: { (isSuccess) in
                    self.store.dispatch(VerificationAddressAction(success:isSuccess))
                })
            }
        default:
            break
        }
    }
    
    func setAsset(_ asset : String) {
        self.store.dispatch(SetAssetAction(data:asset))
    }
    
    func verityNote(_ success : Bool) {
        self.store.dispatch(VerificationNoteAction(data : success))
    }
    
    func addAddress(_ type : address_type) {
        
        if type == .withdraw {
            AddressManager.shared.addWithDrawAddress(WithdrawAddress(id: AddressManager.shared.getUUID(), name: self.state.property.asset.value, address: self.state.property.address.value, currency: self.state.property.note.value, memo: self.state.property.memo.value))
        }
        else {
            AddressManager.shared.addTransferAddress(TransferAddress(id: AddressManager.shared.getUUID(), name: self.state.property.note.value, address: self.state.property.address.value))
        }
    }
}
