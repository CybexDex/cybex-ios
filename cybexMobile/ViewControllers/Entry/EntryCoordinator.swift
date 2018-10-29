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
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<EntryState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class EntryCoordinator: EntryRootCoordinator {

    lazy var creator = EntryPropertyActionCreate()

    var store = Store<EntryState>(
        reducer: entryReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
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

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<EntryState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
}
