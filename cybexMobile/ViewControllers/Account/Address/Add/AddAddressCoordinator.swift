//
//  AddAddressCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

enum AddressType: String {
    case withdraw
    case transfer
}

protocol AddAddressCoordinatorProtocol {
    func pop(_ sender: PopType)
}

protocol AddAddressStateManagerProtocol {
    var state: AddAddressState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<AddAddressState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    func verityAddress(_ address: String, type: AddressType)

    func setAsset(_ asset: String)

    func verityNote(_ success: Bool)

    func addAddress(_ type: AddressType)

    func veritiedAddress(_ type: Bool)

    func setNoteAction(_ note: String)

}

class AddAddressCoordinator: AccountRootCoordinator {

    lazy var creator = AddAddressPropertyActionCreate()

    var store = Store<AddAddressState>(
        reducer: addAddressReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension AddAddressCoordinator: AddAddressCoordinatorProtocol {
    func pop(_ sender: PopType) {
        if sender == .normal {
            self.rootVC.popViewController()
        } else {
            for viewController in self.rootVC.viewControllers {
                if viewController is RechargeViewController {
                    _ = self.rootVC.popToViewController(viewController, animated: true)
                }
            }
        }
    }
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

    func verityAddress(_ address: String, type: AddressType) {
        switch type {
        case .transfer:

            UserManager.shared.checkUserName(address).done({ (exist) in
                main {
                    self.store.dispatch(VerificationAddressAction(success: exist))
                    self.store.dispatch(SetAddressAction(data: address))
                }
            }).cauterize()

        case .withdraw:
            if let assetInfo = appData.assetInfo[self.state.property.asset.value] {

                RechargeDetailCoordinator.verifyAddress(assetInfo.symbol.filterJade, address: address, callback: { (isSuccess) in
                    self.store.dispatch(VerificationAddressAction(success: isSuccess))
                    self.store.dispatch(SetAddressAction(data: address))
                })
            }
        }
    }

    func veritiedAddress(_ type: Bool) {
        self.store.dispatch(VerificationAddressAction(success: type))
    }

    func setAsset(_ asset: String) {
        self.store.dispatch(SetAssetAction(data: asset))
    }

    func verityNote(_ success: Bool) {
        self.store.dispatch(VerificationNoteAction(data: success))
    }

    func addAddress(_ type: AddressType) {

        if type == .withdraw {
            AddressManager.shared.addWithDrawAddress(WithdrawAddress(id: AddressManager.shared.getUUID(),
                                                                     name: self.state.property.note.value,
                                                                     address: self.state.property.address.value,
                                                                     currency: self.state.property.asset.value,
                                                                     memo: self.state.property.memo.value))
        } else {
            AddressManager.shared.addTransferAddress(TransferAddress(id: AddressManager.shared.getUUID(), name: self.state.property.note.value, address: self.state.property.address.value))
        }
    }

    func setNoteAction(_ note: String) {
        self.store.dispatch(SetNoteAction(data: note))
    }
}
