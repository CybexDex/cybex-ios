//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import ReSwift
import SwiftNotificationCenter

protocol ___VARIABLE_productName:identifier___CoordinatorProtocol {
}

protocol ___VARIABLE_productName:identifier___StateManagerProtocol {
    var state: ___VARIABLE_productName:identifier___State { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<___VARIABLE_productName:identifier___State>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class ___VARIABLE_productName:identifier___Coordinator: <#RootCoordinator#> {
    lazy var creator = ___VARIABLE_productName:identifier___PropertyActionCreate()

    var store = Store<___VARIABLE_productName:identifier___State>(
        reducer: ___VARIABLE_productName:identifier___Reducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
        
    override func register() {
        Broadcaster.register(___VARIABLE_productName:identifier___CoordinatorProtocol.self, observer: self)
        Broadcaster.register(___VARIABLE_productName:identifier___StateManagerProtocol.self, observer: self)
    }
}

extension ___VARIABLE_productName:identifier___Coordinator: ___VARIABLE_productName:identifier___CoordinatorProtocol {
    
}

extension ___VARIABLE_productName:identifier___Coordinator: ___VARIABLE_productName:identifier___StateManagerProtocol {
    var state: ___VARIABLE_productName:identifier___State {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<___VARIABLE_productName:identifier___State>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
    
}
