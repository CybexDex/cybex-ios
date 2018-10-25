//
//  WithdrawAddressHomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol WithdrawAddressHomeCoordinatorProtocol {
    func openWithDrawAddressVC()
}

protocol WithdrawAddressHomeStateManagerProtocol {
    var state: WithdrawAddressHomeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressHomeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState

    func fetchData()
    func fetchAddressData()
    func selectCell(_ index: Int)
}

class WithdrawAddressHomeCoordinator: AccountRootCoordinator {
    lazy var creator = WithdrawAddressHomePropertyActionCreate()

    var store = Store<WithdrawAddressHomeState>(
        reducer: WithdrawAddressHomeReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )

    override func register() {
        Broadcaster.register(WithdrawAddressHomeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAddressHomeStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAddressHomeCoordinator: WithdrawAddressHomeCoordinatorProtocol {
    func openWithDrawAddressVC() {
        let vc = R.storyboard.account.withdrawAddressViewController()!
        let coor = WithdrawAddressCoordinator(rootVC: self.rootVC)
        vc.coordinator = coor
        if let viewModel = self.state.property.selectedViewModel.value {
            vc.asset = viewModel.viewModel.model.id
        }
        self.rootVC.pushViewController(vc, animated: true)
    }
}

extension WithdrawAddressHomeCoordinator: WithdrawAddressHomeStateManagerProtocol {
    var state: WithdrawAddressHomeState {
        return store.state
    }

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressHomeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

    func fetchData() {
        SimpleHTTPService.fetchWithdrawIdsInfo().done { (ids) in
            self.store.dispatch(FecthWithdrawIds(data: ids))
        }.cauterize()
    }

    func fetchAddressData() {
        guard self.state.property.data.value.count > 0 else { return }

        var data: [String: [WithdrawAddress]] = [:]

        for viewmodel in self.state.property.data.value {
            data[viewmodel.model.id] = AddressManager.shared.getWithDrawAddressListWith(viewmodel.model.id)
        }

        DispatchQueue.main.async {
            self.store.dispatch(WithdrawAddressHomeAddressDataAction(data: data))
        }
    }

    func selectCell(_ index: Int) {
        self.store.dispatch(WithdrawAddressHomeSelectedAction(index: index))
    }
}
