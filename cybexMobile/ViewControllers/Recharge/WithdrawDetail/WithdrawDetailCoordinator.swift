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
    func fetchDepositAddress(_ asset_name:String)
    func resetDepositAddress(_ asset_name:String)
    func openDepositRecode(_ asset_id : String)
    
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
        reducer: WithdrawDetailReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension WithdrawDetailCoordinator: WithdrawDetailCoordinatorProtocol {
    func fetchDepositAddress(_ asset_name:String){
        if let name = UserManager.shared.name.value {
            async {
                let data = try? await(GraphQLManager.shared.getDepositAddress(accountName: name,assetName: asset_name))
                main {
                    if case let data?? = data {
                        self.store.dispatch(FetchAddressInfo(data: data))
                    }else{
                        self.state.property.data.accept(nil)
                    }
                }
            }
        }
    }
    
    func resetDepositAddress(_ asset_name:String){
        if let name = UserManager.shared.name.value {
            async {
                let data = try? await(GraphQLManager.shared.updateDepositAddress(accountName: name, assetName: asset_name))
                main {
                    if case let data?? = data {
                        self.store.dispatch(FetchAddressInfo(data: data))
                    }else{
                        self.state.property.data.accept(nil)
                    }
                }
            }
        }
    }
    
    func openDepositRecode(_ asset_id : String) {
        if let vc = R.storyboard.recode.rechargeRecodeViewController() {
            vc.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
            vc.assetInfo = app_data.assetInfo[asset_id]
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
