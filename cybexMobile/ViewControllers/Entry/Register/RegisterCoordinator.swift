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
}

class RegisterCoordinator: NavCoordinator {
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
        guard let window = UIApplication.shared.keyWindow else {
            return Presentr(presentationType: .alert)
        }

        let center = ModalCenterPosition.custom(centerPoint: CGPoint(x: window.size.width / 2, y: (window.size.height / 2) - 130))
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let customPresenter = Presentr(presentationType: customType)
        customPresenter.roundCorners = true
        return customPresenter
    }()

    var store = Store<RegisterState>(
        reducer: registerReducer,
        state: nil,
        middleware: [trackingMiddleware]
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
        vc.didConfirm.delegate(on: self) { (self, _) in
            self.dismiss()
        }
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
        appCoodinator.rootVC.dismiss(animated: true, completion: nil)
    }
}

extension RegisterCoordinator: RegisterStateManagerProtocol {
    var state: RegisterState {
        return store.state
    }
}
