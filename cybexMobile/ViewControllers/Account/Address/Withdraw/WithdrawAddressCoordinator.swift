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

protocol WithdrawAddressCoordinatorProtocol {
    func openActionVC()
}

protocol WithdrawAddressStateManagerProtocol {
    var state: WithdrawAddressState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawAddressState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
    
    func refreshData(_ id:String?)
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
        
//        let actionController = PeriscopeActionController()
//        actionController.selectedIndex = IndexPath(row: UserManager.shared.frequency_type.rawValue, section: 0)
//
//        actionController.addAction(Action(R.string.localizable.frequency_normal.key.localized(), style: .destructive, handler: {[weak self] action in
//            guard let `self` = self else {return}
//            UserManager.shared.frequency_type = .normal
//            self.frequency.content_locali = UserManager.shared.frequency_type.description()
//        }))
//
//        actionController.addAction(Action(R.string.localizable.frequency_time.key.localized(), style: .destructive, handler: { [weak self]action in
//            guard let `self` = self else {return}
//
//            UserManager.shared.frequency_type = .time
//            self.frequency.content_locali = UserManager.shared.frequency_type.description()
//
//        }))
//
//        actionController.addAction(Action(R.string.localizable.frequency_wifi.key.localized(), style: .destructive, handler: { [weak self]action in
//            guard let `self` = self else {return}
//            UserManager.shared.frequency_type = .WiFi
//            self.frequency.content_locali = UserManager.shared.frequency_type.description()
//        }))
//
//        actionController.addSection(PeriscopeSection())
//        actionController.addAction(Action(R.string.localizable.alert_cancle.key.localized(), style: .cancel, handler: { action in
//        }))
//
//        present(actionController, animated: true, completion: nil)
        
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
}
