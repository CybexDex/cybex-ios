//
//  WithdrawDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift

protocol WithdrawDetailCoordinatorProtocol {
    func fetchDepositAddress(_ assetName: String)
    func resetDepositAddress(_ assetName: String)
    func openDepositRecode(_ assetId: String)

}

protocol WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawDetailState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState
}

class WithdrawDetailCoordinator: AccountRootCoordinator {

    lazy var creator = WithdrawDetailPropertyActionCreate()

    var store = Store<WithdrawDetailState>(
        reducer: withdrawDetailReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension WithdrawDetailCoordinator: WithdrawDetailCoordinatorProtocol {
    func fetchDepositAddress(_ assetName: String) {
        if let name = UserManager.shared.name.value {
            async {
                let data = try? await(GraphQLManager.shared.getDepositAddress(accountName: name, assetName: assetName))
                main {
                    if case let data?? = data {
                        self.store.dispatch(FetchAddressInfo(data: data))
                    } else {
                        self.state.property.data.accept(nil)
                    }
                }
            }
        }
    }

    func resetDepositAddress(_ assetName: String) {
        if let name = UserManager.shared.name.value {
            async {
                let data = try? await(GraphQLManager.shared.updateDepositAddress(accountName: name, assetName: assetName))
                main {
                    if case let data?? = data {
                        self.store.dispatch(FetchAddressInfo(data: data))
                    } else {
                        self.state.property.data.accept(nil)
                    }
                }
            }
        }
    }

    func openDepositRecode(_ assetId: String) {
        if let vc = R.storyboard.recode.rechargeRecodeViewController() {
            vc.recordType = .DEPOSIT
            vc.assetInfo = appData.assetInfo[assetId]
            vc.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension WithdrawDetailCoordinator: WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState {
        return store.state
    }

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<WithdrawDetailState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
}
