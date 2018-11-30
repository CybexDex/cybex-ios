//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol ___VARIABLE_productName:identifier___CoordinatorProtocol {
}

protocol ___VARIABLE_productName:identifier___StateManagerProtocol {
    var state: ___VARIABLE_productName:identifier___State { get }
    
    func switchPageState(_ state:PageState)
}

class ___VARIABLE_productName:identifier___Coordinator: NavCoordinator {
    var store = Store(
        reducer: g___VARIABLE_productName:identifier___Reducer,
        state: nil,
        middleware:[trackingMiddleware]
    )
    
    var state: ___VARIABLE_productName:identifier___State {
        return store.state
    }
    
    override class func start(_ root: BaseNavigationController, context:RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.<#name#>!
        let coordinator = ___VARIABLE_productName:identifier___Coordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }

    override func register() {
        Broadcaster.register(___VARIABLE_productName:identifier___CoordinatorProtocol.self, observer: self)
        Broadcaster.register(___VARIABLE_productName:identifier___StateManagerProtocol.self, observer: self)
    }
}

extension ___VARIABLE_productName:identifier___Coordinator: ___VARIABLE_productName:identifier___CoordinatorProtocol {
    
}

extension ___VARIABLE_productName:identifier___Coordinator: ___VARIABLE_productName:identifier___StateManagerProtocol {
    func switchPageState(_ state:PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }
}
