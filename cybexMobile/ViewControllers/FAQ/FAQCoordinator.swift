//
//  FAQCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol FAQCoordinatorProtocol {
}

protocol FAQStateManagerProtocol {
    var state: FAQState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<FAQState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class FAQCoordinator: FAQRootCoordinator {
    
    lazy var creator = FAQPropertyActionCreate()
    
    var store = Store<FAQState>(
        reducer: FAQReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: FAQState {
        return store.state
    }
}

extension FAQCoordinator: FAQCoordinatorProtocol {
    
}

extension FAQCoordinator: FAQStateManagerProtocol {
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<FAQState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
