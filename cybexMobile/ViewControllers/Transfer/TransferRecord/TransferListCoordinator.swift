//
//  TransferListCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol TransferListCoordinatorProtocol {
    
    func openTransferDetail(_ sender: TransferRecordViewModel)
}

protocol TransferListStateManagerProtocol {
    var state: TransferListState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferListState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState
    
    func reduceTransferRecords()
}

class TransferListCoordinator: AccountRootCoordinator {
    
    lazy var creator = TransferListPropertyActionCreate()
    
    var store = Store<TransferListState>(
        reducer: transferListReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension TransferListCoordinator: TransferListCoordinatorProtocol {
    func openTransferDetail(_ sender: TransferRecordViewModel) {
        if let vc = R.storyboard.recode.transferDetailViewController() {
            vc.coordinator = TransferDetailCoordinator(rootVC: self.rootVC)
            vc.data  = sender
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension TransferListCoordinator: TransferListStateManagerProtocol {
    var state: TransferListState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TransferListState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
    func reduceTransferRecords() {
        if let data = UserManager.shared.transferRecords.value {
            self.store.dispatch(ReduceTansferRecordsAction(data: data))
        }
    }
}
