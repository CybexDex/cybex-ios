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
}

class ___VARIABLE_productName:identifier___Coordinator: <#RootCoordinator#> {
    var store = Store(
        reducer: ___VARIABLE_productName:identifier___Reducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: ___VARIABLE_productName:identifier___State {
        return store.state
    }
            
    override func register() {
        Broadcaster.register(___VARIABLE_productName:identifier___CoordinatorProtocol.self, observer: self)
        Broadcaster.register(___VARIABLE_productName:identifier___StateManagerProtocol.self, observer: self)
    }
}

extension ___VARIABLE_productName:identifier___Coordinator: ___VARIABLE_productName:identifier___CoordinatorProtocol {
    
}

extension ___VARIABLE_productName:identifier___Coordinator: ___VARIABLE_productName:identifier___StateManagerProtocol {
    
}
