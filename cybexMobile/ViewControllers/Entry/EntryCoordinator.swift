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
  func switchToRegister()
  func dismiss()
}

protocol EntryStateManagerProtocol {
    var state: EntryState { get }
}

class EntryCoordinator: NavCoordinator {
    var store = Store<EntryState>(
        reducer: entryReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.main.entryViewController()!
        let coordinator = EntryCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))
        return vc
    }
}

extension EntryCoordinator: EntryCoordinatorProtocol {
  func switchToRegister() {
    let vc = R.storyboard.main.registerViewController()!
    let coordinator = RegisterCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator

    UIView.beginAnimations("register", context: nil)
    UIView.setAnimationCurve(.easeInOut)
    UIView.setAnimationDuration(0.7)
    UIView.setAnimationTransition(.flipFromLeft, for: self.rootVC.view, cache: false)
    self.rootVC.pushViewController(vc, animated: false)
    UIView.commitAnimations()
  }

  func dismiss() {
    appCoodinator.rootVC.dismiss(animated: true, completion: nil)
  }
}

extension EntryCoordinator: EntryStateManagerProtocol {
    var state: EntryState {
        return store.state
    }

}
