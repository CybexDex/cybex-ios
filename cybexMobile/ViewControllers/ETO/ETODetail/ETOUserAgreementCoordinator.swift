//
//  ETOUserAgreementCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol ETOUserAgreementCoordinatorProtocol {
}

protocol ETOUserAgreementStateManagerProtocol {
    var state: ETOUserAgreementState { get }

    func switchPageState(_ state: PageState)
}

class ETOUserAgreementCoordinator: ETORootCoordinator {
    var store = Store(
        reducer: ETOUserAgreementReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )

    var state: ETOUserAgreementState {
        return store.state
    }

    override func register() {
        Broadcaster.register(ETOUserAgreementCoordinatorProtocol.self, observer: self)
        Broadcaster.register(ETOUserAgreementStateManagerProtocol.self, observer: self)
    }
}

extension ETOUserAgreementCoordinator: ETOUserAgreementCoordinatorProtocol {

}

extension ETOUserAgreementCoordinator: ETOUserAgreementStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
//        var context = ETODetailContext()
//        context.pid = 100
//        self.pushVC(ETODetailCoordinator.self, animated: true, context: context)
    }
}
