//
//  EntryCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol EntryCoordinatorProtocol {
  func dismiss()
}

protocol EntryStateManagerProtocol {
    var state: EntryState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<EntryState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class EntryCoordinator: EntryRootCoordinator {
    
    lazy var creator = EntryPropertyActionCreate()
    
    var store = Store<EntryState>(
        reducer: EntryReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension EntryCoordinator: EntryCoordinatorProtocol {
  func dismiss() {
    app_coodinator.rootVC.dismiss(animated: true, completion: nil)
  }
}

extension EntryCoordinator: EntryStateManagerProtocol {
    var state: EntryState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<EntryState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
}
