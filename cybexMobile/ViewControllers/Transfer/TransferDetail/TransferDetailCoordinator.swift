//
//  TransferDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol TransferDetailCoordinatorProtocol {
}

protocol TransferDetailStateManagerProtocol {
    var state: TransferDetailState { get }
}

class TransferDetailCoordinator: NavCoordinator {
    var store = Store<TransferDetailState>(
        reducer: transferDetailReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension TransferDetailCoordinator: TransferDetailCoordinatorProtocol {

}

extension TransferDetailCoordinator: TransferDetailStateManagerProtocol {
    var state: TransferDetailState {
        return store.state
    }

}
