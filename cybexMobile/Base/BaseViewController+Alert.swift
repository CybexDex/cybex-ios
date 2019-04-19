//
//  BaseViewController+Alert.swift
//  cybexMobile
//
//  Created by koofrank on 2019/3/11.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation

extension UIViewController: ShowManagerDelegate {
    func showToastBox(_ success: Bool, message: String, manager: ShowToastManager = ShowToastManager.shared) {
        if manager.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(titleImage: success ? R.image.icCheckCircleGreen.name : R.image.erro16Px.name,
                                          message: message,
                                          animationType: .smallBig, showType: .alertImage)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.hide(2.0)
        }
    }

    func showToast(message: String, manager: ShowToastManager = ShowToastManager.shared) {
        if manager.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(message: message,
                                          animationType: .smallBig, showType: .alertImage)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.hide(2.0)
        }
    }

    func showPasswordBox(_ title: String = R.string.localizable.withdraw_unlock_wallet.key.localized(), hintKey: String = "", middleType: CybexTextView.TextViewType = .normal, tag: String = "") {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }

        let passwordView = CybexPasswordView(frame: .zero)
        passwordView.hint.locali = hintKey

        delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(title: title, contentView: passwordView, animationType: .smallBig, middleType: middleType, tag: tag)
            ShowToastManager.shared.delegate = self
            ShowToastManager.shared.showAnimationInView(self.view)
        }
    }

    func showPureContentConfirm(_ title: String = R.string.localizable.tip_title.key.localized(), rightTitleLocali: String = "", ensureButtonLocali: String = R.string.localizable.alert_ensure.key, content: String = "openedorder_ensure_message", tag: String = "") {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        delay(milliseconds: 100) {
            let subView = CybexShowTitleView(frame: .zero)
            subView.title.locali = ""
            subView.contentLable.locali = content

            ShowToastManager.shared.setUp(title: title, contentView: subView, rightTitleLocali: rightTitleLocali, ensureButtonLocali: ensureButtonLocali, animationType: .smallBig, middleType: .normal, tag: tag)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func showConfirm(_ title: String, attributes: [NSAttributedString]?, rightTitleLocali: String = "", tag: String = "", setup: (([StyleLabel]) -> Void)? = nil) {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        delay(milliseconds: 100) {
            let subView = StyleContentView(frame: .zero)
            subView.data = attributes
            setup?(subView.labels)

            ShowToastManager.shared.setUp(title: title, contentView: subView, rightTitleLocali: rightTitleLocali, animationType: .smallBig, middleType: .normal, tag: tag)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func showConfirmImage(_ titleImage: String, title: String, content: String, tag: String = "") {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        delay(milliseconds: 100) {
            let subView = CybexShowTitleView(frame: .zero)
            subView.title.locali = title
            subView.contentLable.locali = content
            ShowToastManager.shared.setUp(titleImage: titleImage, contentView: subView, animationType: .smallBig, tag: tag)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func showWaiting(_ title: String, content: String, time: Int, tag: String = "") {
        if ShowToastManager.shared.showView != nil {
            ShowToastManager.shared.hide(0)
        }
        delay(milliseconds: 100) {
            ShowToastManager.shared.setUp(title, content: content, time: time, animationType: ShowToastManager.ShowAnimationType.smallBig, tag: tag)
            ShowToastManager.shared.showAnimationInView(self.view)
            ShowToastManager.shared.delegate = self
        }
    }

    func returnEnsureAction() {
    }

    func returnEnsureActionWithData(_ tag: String) {

    }


    func returnEnsureImageAction() {

    }

    func cancelImageAction(_ tag: String) {

    }

    @objc func passwordPassed(_ passed: Bool) {
        
    }

    @objc func passwordDetecting() {

    }

    @objc func codePassed(_ passed: Bool) {

    }

    func returnUserPassword(_ sender: String, textView: CybexTextView) {
        ShowToastManager.shared.hide()

        passwordDetecting()

        UserManager.shared.unlock(nil, password: sender).done { (_) in
            self.passwordPassed(true)
            }.catch { (_) in
                self.passwordPassed(false)
        }
    }

    func ensureWaitingAction(_ sender: CybexWaitingView) {

    }

    func returnInviteCode(_ sender: String) {

    }

    @objc func didClickedRightAction(_ tag: String) {
        
    }
}
