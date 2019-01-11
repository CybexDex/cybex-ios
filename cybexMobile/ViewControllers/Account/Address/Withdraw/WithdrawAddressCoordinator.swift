//
//  WithdrawAddressCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import XLActionController

protocol WithdrawAddressCoordinatorProtocol {
    func openActionVC(_ dismissCallback: CommonCallback?)

    func openAddWithdrawAddress()
}

protocol WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState { get }

    func refreshData()
    func select(_ address: WithdrawAddress?)
    func copy()
    func confirmdelete()
    func delete()

    func isEOS() -> Bool
    
    func isXRP() -> Bool
}

class WithdrawAddressCoordinator: NavCoordinator {

    var store = Store<WithdrawAddressState>(
        reducer: withdrawAddressReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override func register() {
        Broadcaster.register(WithdrawAddressCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAddressStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAddressCoordinator: WithdrawAddressCoordinatorProtocol {
    func openActionVC(_ dismissCallback: CommonCallback?) {
        let actionController = PeriscopeActionController()
        actionController.tapMaskCallback = dismissCallback

        actionController.addAction(Action(R.string.localizable.copy.key.localized(), style: .destructive, handler: {[weak self] _ in
            guard let self = self else {return}
            self.copy()
            dismissCallback?()
        }))

        actionController.addAction(Action(R.string.localizable.delete.key.localized(), style: .destructive, handler: {[weak self] _ in
            guard let self = self else {return}
            self.confirmdelete()
            dismissCallback?()
        }))

        actionController.addSection(PeriscopeSection())
        actionController.addAction(Action(R.string.localizable.alert_cancle.key.localized(), style: .cancel, handler: {[weak self] _ in
            guard let self = self else {return}

            self.select(nil)
            dismissCallback?()
        }))

        self.rootVC.topViewController?.present(actionController, animated: true, completion: nil)
    }

    func openAddWithdrawAddress() {
        Broadcaster.notify(WithdrawAddressHomeStateManagerProtocol.self) { (coor) in
            if let viewmodel = coor.state.selectedViewModel.value {
                let id = viewmodel.viewModel.model.id
                if let vc = R.storyboard.account.addAddressViewController() {
                    vc.coordinator = AddAddressCoordinator(rootVC: self.rootVC)
                    vc.addressType = .withdraw
                    vc.asset = id
                    self.rootVC.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension WithdrawAddressCoordinator: WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState {
        return store.state
    }

    func refreshData() {
        Broadcaster.notify(WithdrawAddressHomeStateManagerProtocol.self) { (coor) in
            if let viewmodel = coor.state.selectedViewModel.value {
                let id = viewmodel.viewModel.model.id

                let list = AddressManager.shared.getWithDrawAddressListWith(id)

                let names = list.map { (info) -> AddressName in
                    return AddressName(name: info.name)
                }

                let sortedNames = AddressHelper.sortNameBasedonAddress(names)

                let data = list.sorted { (front, last) -> Bool in
                    return sortedNames.index(of: front.name)! <= sortedNames.index(of: last.name)!
                }

                self.store.dispatch(WithdrawAddressDataAction(data: data))
            }
        }
    }

    func select(_ address: WithdrawAddress?) {
        self.store.dispatch(WithdrawAddressSelectDataAction(data: address))
    }

    func isEOS() -> Bool {
        var result = false
        Broadcaster.notify(WithdrawAddressHomeStateManagerProtocol.self) { (coor) in
            if let viewmodel = coor.state.selectedViewModel.value {
                if viewmodel.viewModel.model.id == AssetConfiguration.CybexAsset.EOS.id {
                    result = true
                }
            }
        }
        return result
    }
    
    func isXRP() -> Bool {
        var result = false
        Broadcaster.notify(WithdrawAddressHomeStateManagerProtocol.self) { (coor) in
            if let viewmodel = coor.state.selectedViewModel.value {
                if viewmodel.viewModel.model.id == "1.3.999" {
                    result = true
                }
            }
        }
        return result
    }

    func copy() {
        if let addressData = self.state.selectedAddress.value {
            if addressData.currency == AssetConfiguration.CybexAsset.EOS.id || addressData.currency == AssetConfiguration.CybexAsset.XRP.id {
                if let memo = addressData.memo {
                    UIPasteboard.general.string = addressData.address + "(\(memo))"
                } else {
                     UIPasteboard.general.string = addressData.address
                }
            }
            else {
                UIPasteboard.general.string = addressData.address
            }

            self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.copied.key.localized())
        }
    }

    func confirmdelete() {
        if let addressData = self.state.selectedAddress.value {
            self.rootVC.topViewController?.showConfirm(R.string.localizable.address_delete_confirm.key.localized(), attributes: UIHelper.confirmDeleteWithDrawAddress(addressData), setup: { (labels) in
                for label in labels {
                    label.content.numberOfLines = 1
                    label.content.lineBreakMode = .byTruncatingMiddle
                }
            })

        }
    }

    func delete() {
        if let addressData = self.state.selectedAddress.value {
            AddressManager.shared.removeWithDrawAddress(addressData.id)

            DispatchQueue.main.async {
                self.rootVC.topViewController?.showToastBox(true, message: R.string.localizable.deleted.key.localized())
            }
        }

    }
}
