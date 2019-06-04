//
//  EntryViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import SwiftyUserDefaults
import CoreNFC

class EntryViewController: BaseViewController {

    var coordinator: (EntryCoordinatorProtocol & EntryStateManagerProtocol)?

    @IBOutlet weak var accountTextField: ImageTextField!
    @IBOutlet weak var passwordTextField: ImageTextField!

    @IBOutlet weak var createTitle: UILabel!
    @IBOutlet weak var loginButton: Button!
    @IBOutlet weak var enotesLogin: UILabel!

    var card: Card? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

//        self.enotesLogin.isHidden = true

        if #available(iOS 11.0, *) {
            self.enotesLogin.isHidden = !NFCNDEFReaderSession.readingAvailable
        } else {
            self.enotesLogin.isHidden = true
        }

        setupEvent()
    }

    func setupUI() {
        configLeftNavigationButton(R.image.icClose24Px())
        accountTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        passwordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        accountTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        passwordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
    }

    @objc override func leftAction(_ sender: UIButton) {
        coordinator?.dismiss()
    }

    override func configureObserveState() {

    }
}

extension EntryViewController {
    func setupEvent() {
        let accountValid = accountTextField.rx.text.orEmpty.map { $0.count > 0 }.share(replay: 1)

        let passwordValid = passwordTextField.rx.text.orEmpty.map { $0.count > 0}.share(replay: 1)

        Observable.combineLatest(accountValid, passwordValid) {
            return $0 && $1
            }.bind {[weak self] (valid) in
                guard let self = self else { return }

                if valid {
                    self.loginButton.isEnable = true
                } else {
                    self.loginButton.isEnable = false
                }
            }.disposed(by: disposeBag)

        self.createTitle.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }

            self.coordinator?.switchToRegister()
        }).disposed(by: disposeBag)

        self.enotesLogin.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }

            self.coordinator?.switchToEnotesLogin({[weak self] (card) in
                self?.card = card
                self?.showPasswordBox(R.string.localizable.enotes_pin_validtor_title.key.localized(), middleType: .normal)
            }, error: { (card) in

            })
        }).disposed(by: disposeBag)

        self.loginButton.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }

            self.startLoading()

            UserManager.shared.login(self.accountTextField.text!, password: self.passwordTextField.text!).done {
                NotificationCenter.default.post(name: NSNotification.Name.init("login_success"), object: nil)
                self.coordinator?.dismiss()
            }.ensure {
                self.endLoading()
            }.catch {_ in
                self.showAlert(R.string.localizable.accountNonMatch.key.localized(), buttonTitle: R.string.localizable.ok.key.localized())
            }
        }).disposed(by: disposeBag)
    }

    override func passwordPassed(_ passed: Bool) {
        if passed {
            ShowToastManager.shared.hide()
        } else {
            ShowToastManager.shared.data = R.string.localizable.enotes_password_wrong.key.localized()
        }
    }

    override func returnUserPassword(_ sender: String, textView: CybexTextView) {
        if let card = self.card, card.validatorPin(sender).success {
            UserManager.shared.enotesLogin(card.base58PubKey, account: card.account).done {
                Defaults[.pinCodes][card.base58PubKey] = sender
                self.passwordPassed(true)
                self.coordinator?.dismiss()
                }.catch({ (error) in
                    self.passwordPassed(true)
                    self.showToastBox(false, message: R.string.localizable.enotes_not_match.key.localized())
                })
        }
        else {
            self.passwordPassed(false)
        }
    }
}
