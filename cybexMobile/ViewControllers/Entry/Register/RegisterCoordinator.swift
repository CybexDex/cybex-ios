//
//  RegisterCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Presentr

protocol RegisterCoordinatorProtocol {
  func pushCreateTip()
  func switchToLogin()
  func confirmRegister(_ password: String)
  func dismiss()
}

protocol RegisterStateManagerProtocol {
  var state: RegisterState { get }
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<RegisterState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState
}

class RegisterCoordinator: EntryRootCoordinator {
  let presenter: Presentr = {
    let width = ModalSize.custom(size: 272)
    let height = ModalSize.custom(size: 340)
    let center = ModalCenterPosition.center
    let customType = PresentationType.custom(width: width, height: height, center: center)

    let customPresenter = Presentr(presentationType: customType)
    customPresenter.roundCorners = true
    return customPresenter
  }()

  let codePresenter: Presentr = {
    let width = ModalSize.custom(size: 272)
    let height = ModalSize.custom(size: 226)
    let center = ModalCenterPosition.custom(centerPoint: CGPoint(x: UIApplication.shared.keyWindow!.width / 2, y: (UIApplication.shared.keyWindow!.height / 2) - 130))
    let customType = PresentationType.custom(width: width, height: height, center: center)

    let customPresenter = Presentr(presentationType: customType)
    customPresenter.roundCorners = true
    return customPresenter
  }()

  lazy var creator = RegisterPropertyActionCreate()

  var store = Store<RegisterState>(
    reducer: RegisterReducer,
    state: nil,
    middleware: [TrackingMiddleware]
  )
}

extension RegisterCoordinator: RegisterCoordinatorProtocol {
  func pushCreateTip() {
    let vc = R.storyboard.main.registerTipViewController()!
      self.rootVC.pushViewController(vc, animated: true)
  }

  func confirmRegister(_ password: String) {
    let vc = R.storyboard.main.noticeBoardViewController()!
    vc.password = password
    vc.coordinator = self
    self.rootVC.topViewController?.customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
  }

  func switchToLogin() {
    UIView.beginAnimations("login", context: nil)
    UIView.setAnimationCurve(.easeInOut)
    UIView.setAnimationDuration(0.7)
    UIView.setAnimationTransition(.flipFromRight, for: self.rootVC.view, cache: false)
    self.rootVC.popViewController(animated: true)
    UIView.commitAnimations()
  }

  func dismiss() {
    app_coodinator.rootVC.dismiss(animated: true, completion: nil)
  }
}

extension RegisterCoordinator: RegisterStateManagerProtocol {
  var state: RegisterState {
    return store.state
  }

  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<RegisterState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }

}
