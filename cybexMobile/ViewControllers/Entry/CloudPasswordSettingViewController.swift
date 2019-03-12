//
//  CloudPasswordSettingViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2019/3/11.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import UIKit
import SwiftTheme
import RxSwift
import RxCocoa

class CloudPasswordSettingViewController: BaseViewController {

    @IBOutlet weak var passwordTextField: ImageTextField!
    @IBOutlet weak var confirmPasswordTextField: ImageTextField!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var passwordRuleHint: UILabel!
    @IBOutlet weak var ensureButton: Button!

    var passwordValid = false
    var confirmValid = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = R.string.localizable.enotes_cloudpassword_title.key.localized()
        setupUI()

        setupPasswordEvent()
        setupRegisterButtonEvent()
    }

    func setupUI() {
        passwordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        confirmPasswordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        passwordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        confirmPasswordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey

        passwordTextField.activityView?.isHidden = true
        passwordTextField.tailImage = nil
        confirmPasswordTextField.activityView?.isHidden = true
        confirmPasswordTextField.tailImage = nil

    }

    func setupPasswordEvent() {
        let passwordValid = self.passwordTextField.rx.text.orEmpty.map({ UserHelper.verifyPassword($0) }).share(replay: 1)
        let confirmPasswordValid = self.confirmPasswordTextField.rx.text.orEmpty.map({ UserHelper.verifyPassword($0) }).share(replay: 1)

        passwordValid.subscribe(onNext: {[weak self] (validate) in
            guard let self = self else { return }
            self.passwordValid = validate
            if validate {
                self.passwordTextField.tailImage = R.image.check_complete()
                if let confirm = self.confirmPasswordTextField.text, confirm.count > 0, self.passwordTextField.text != confirm {
                    self.errorStackView.isHidden = false
                    self.passwordRuleHint.text = R.string.localizable.passwordValidateError2.key.localized()
                    self.passwordTextField.tailImage = nil
                    return
                }

                self.errorStackView.isHidden = true
            } else {
                self.passwordTextField.tailImage = nil
                if let text = self.passwordTextField.text, text.count == 0 {
                    if !self.confirmValid, let confirm = self.confirmPasswordTextField.text, confirm.count > 0 {
                        self.errorStackView.isHidden = false
                        self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
                        return
                    }

                    self.errorStackView.isHidden = true
                    return
                }
                self.errorStackView.isHidden = false
                self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        confirmPasswordValid.subscribe(onNext: {[weak self] (validate) in
            guard let self = self else { return }
            self.confirmValid = validate

            if validate {
                self.confirmPasswordTextField.tailImage = R.image.check_complete()
                if !self.passwordValid || self.passwordTextField.text != self.confirmPasswordTextField.text {
                    self.errorStackView.isHidden = false
                    self.confirmPasswordTextField.tailImage = nil
                    self.passwordRuleHint.text = R.string.localizable.passwordValidateError2.key.localized()
                    return
                }

                self.errorStackView.isHidden = true
            } else {
                self.confirmPasswordTextField.tailImage = nil
                if let text = self.confirmPasswordTextField.text, text.count == 0 {
                    if !self.passwordValid, let password = self.passwordTextField.text, password.count > 0 {
                        self.errorStackView.isHidden = false
                        self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
                        return
                    }

                    self.errorStackView.isHidden = true
                    return
                }
                self.errorStackView.isHidden = false
                self.passwordRuleHint.text = R.string.localizable.passwordValidateError3.key.localized()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        let consistent = Observable.combineLatest(self.passwordTextField.rx.text, self.confirmPasswordTextField.rx.text).map({$0 == $1})

        Observable.combineLatest(passwordValid, confirmPasswordValid, consistent).subscribe(onNext: {[weak self] (cond) in
            guard let self = self else { return }

            self.ensureButton.isEnable = cond.0 && cond.1 && cond.2

        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

    }

    func setupRegisterButtonEvent() {
        self.ensureButton.rx.tapGesture().when(.recognized).filter {[weak self] (_) -> Bool in
            guard let self = self else { return false }

            return self.ensureButton.canRepeat

            }.subscribe(onNext: {[weak self] (_) in
                guard let self = self else { return }

                self.ensureButton.canRepeat = false

                self.startLoading()

                let password = self.passwordTextField.text ?? ""

                let jsonstr = ""
                
                let withdrawRequest = BroadcastTransactionRequest(response: { (data) in
                    self.endLoading()
                    if String(describing: data) == "<null>"{
                        self.showToastBox(true, message: R.string.localizable.lockup_asset_claim_success.key.localized())
                    } else {
                        self.showToastBox(false, message: R.string.localizable.lockup_asset_claim_fail.key.localized())
                    }
                }, jsonstr: jsonstr)

                CybexWebSocketService.shared.send(request: withdrawRequest)

            }).disposed(by: disposeBag)
    }

}
