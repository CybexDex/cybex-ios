//
//  RegisterViewController.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReSwift
import SwiftTheme
import AwaitKit
import Macaw
import Repeat
import PromiseKit
import Device
//import IHKeyboardAvoiding


class RegisterViewController: BaseViewController {
    
    @IBOutlet weak var iconTopContainer: NSLayoutConstraint!
    var coordinator: (RegisterCoordinatorProtocol & RegisterStateManagerProtocol)?
    
    @IBOutlet weak var accountTextField: ImageTextField!
    @IBOutlet weak var passwordTextField: ImageTextField!
    @IBOutlet weak var confirmPasswordTextField: ImageTextField!
    
    @IBOutlet weak var loginTitle: UILabel!
    @IBOutlet weak var tip: UIImageView!
    @IBOutlet weak var registerButton: Button!
    
    @IBOutlet weak var codeTextField: ImageTextField!
    
    @IBOutlet weak var macawView: MacawView!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var pinCodeActivityView: UIActivityIndicatorView!
    @IBOutlet weak var errorMessage: UILabel!
    
    @IBOutlet weak var titleL: UILabel!
    
    var timer:Repeater?
    
    var pinID:String = ""
    var passwordValid = false
    var confirmValid = false
    var codeValid = false

    var userNameValid = false {
        didSet {
            if userNameValid , let password = self.passwordTextField.text, password.count > 11 , self.passwordTextField.text == self.confirmPasswordTextField.text, let code = self.codeTextField.text, code.count == 4 {
                self.registerButton.isEnable = true
            }
            else {
                self.registerButton.isEnable = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupEvent()
        
        updateSvgView()
        
    }
    
    func updateSvgView() {
        self.pinCodeActivityView.startAnimating()
        
        async {
            let data = try! await(SimpleHTTPService.requestPinCode())
            
            main {
                self.pinCodeActivityView.stopAnimating()
                self.pinID = data.id
                
                if let parser = try? SVGParser.parse(text: data.data) {
                    self.macawView.node = parser
                }
            }
        }
    }
    
    func setupUI() {
        accountTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        passwordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        confirmPasswordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        codeTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
        
        accountTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        passwordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        confirmPasswordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        codeTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
        
        accountTextField.activityView?.isHidden = true
        accountTextField.tailImage = nil
        passwordTextField.activityView?.isHidden = true
        passwordTextField.tailImage = nil
        confirmPasswordTextField.activityView?.isHidden = true
        confirmPasswordTextField.tailImage = nil
        
        macawView.backgroundColor = UIColor.peach
        if Device.size() == .screen3_5Inch || Device.size() == .screen4Inch{
            titleL.font = UIFont.systemFont(ofSize: 11)
        }
    }
    
    @objc override func leftAction(_ sender: UIButton) {
        coordinator?.dismiss()
    }
    
    
    override func configureObserveState() {
        
    }
    
    deinit {
        self.timer?.pause()
        self.timer = nil
    }
}

extension RegisterViewController {
    func setupEvent() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            let userinfo: NSDictionary = notification.userInfo! as NSDictionary
            let nsValue = userinfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRec = nsValue.cgRectValue
            
            if self.iconTopContainer.constant == 15 {
                let distance = abs(self.view.height - self.errorStackView.bottom - keyboardRec.height)
                self.iconTopContainer.constant = self.iconTopContainer.constant - distance + 10
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (notification) in
            self.iconTopContainer.constant = 15
        }
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: accountTextField, queue: nil) {[weak self] (notifi) in
            guard let `self` = self else { return }
            self.errorStackView.isHidden = true
            self.accountTextField.activityView?.isHidden = true
            self.accountTextField.tailImage = nil
            self.userNameValid = false
            
            guard let name = self.accountTextField.text, name.count > 0 else {
                
                self.passwordTextField.text = self.passwordTextField.text
                self.confirmPasswordTextField.text = self.confirmPasswordTextField.text
                return
            }
            
            let (passed, message) = UserManager.shared.validateUserName(name)
            if !passed {
                self.errorStackView.isHidden = false
                self.errorMessage.text = message
            }
            else {
                self.errorStackView.isHidden = true
                
                self.accountTextField.activityView?.isHidden = false
                UserManager.shared.checkUserName(name).done({ (exist) in
                    main {
                        self.accountTextField.activityView?.isHidden = true
                        if !exist {
                            self.accountTextField.tailImage = #imageLiteral(resourceName: "check_complete")
                            self.userNameValid = true
                            self.passwordTextField.text = self.passwordTextField.text
                            self.confirmPasswordTextField.text = self.confirmPasswordTextField.text
                        }
                        else {
                            self.errorStackView.isHidden = false
                            self.errorMessage.text = R.string.localizable.accountValidateError1.key.localized()
                        }
                    }
                }).cauterize()
            }
        }
        
        let passwordValid = self.passwordTextField.rx.text.orEmpty.map({ verifyPassword($0) }).share(replay: 1)
        let confirmPasswordValid = self.confirmPasswordTextField.rx.text.orEmpty.map({ verifyPassword($0) }).share(replay: 1)
        
        passwordValid.subscribe(onNext: {[weak self] (validate) in
            guard let `self` = self else { return }
            self.passwordValid = validate
            if validate {
                self.passwordTextField.tailImage = #imageLiteral(resourceName: "check_complete")
                if let confirm = self.confirmPasswordTextField.text, confirm.count > 0, self.passwordTextField.text != confirm {
                    self.errorStackView.isHidden = false
                    self.errorMessage.text = R.string.localizable.passwordValidateError2.key.localized()
                    return
                }

                if !self.userNameValid, let account = self.accountTextField.text, account.count > 0 {
                    self.errorStackView.isHidden = false
                    self.errorMessage.text = R.string.localizable.accountValidateError6.key.localized()
                    return
                }
                self.errorStackView.isHidden = true
            }
            else {
                self.passwordTextField.tailImage = nil
                if let text = self.passwordTextField.text, text.count == 0 {
                    if !self.confirmValid, let confirm = self.confirmPasswordTextField.text, confirm.count > 0 {
                        self.errorStackView.isHidden = false
                        self.errorMessage.text = R.string.localizable.passwordValidateError3.key.localized()
                        return
                    }
                    if !self.userNameValid, let account = self.accountTextField.text, account.count > 0 {
                        self.errorStackView.isHidden = false
                        self.errorMessage.text = R.string.localizable.accountValidateError6.key.localized()
                        return
                    }
                    self.errorStackView.isHidden = true
                    return
                }
                self.errorStackView.isHidden = false
                self.errorMessage.text = R.string.localizable.passwordValidateError3.key.localized()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        confirmPasswordValid.subscribe(onNext: {[weak self] (validate) in
            guard let `self` = self else { return }
            self.confirmValid = validate
            
            if validate {
                self.confirmPasswordTextField.tailImage = #imageLiteral(resourceName: "check_complete")
                if !self.passwordValid || self.passwordTextField.text != self.confirmPasswordTextField.text {
                    self.errorStackView.isHidden = false
                    self.errorMessage.text = R.string.localizable.passwordValidateError2.key.localized()
                    return
                }
                
                if !self.userNameValid, let account = self.accountTextField.text, account.count > 0 {
                    self.errorStackView.isHidden = false
                    self.errorMessage.text = R.string.localizable.accountValidateError6.key.localized()
                    return
                }
                self.errorStackView.isHidden = true
            }
            else {
                self.confirmPasswordTextField.tailImage = nil
                if let text = self.confirmPasswordTextField.text, text.count == 0 {
                    if !self.passwordValid, let password = self.passwordTextField.text, password.count > 0 {
                        self.errorStackView.isHidden = false
                        self.errorMessage.text = R.string.localizable.passwordValidateError3.key.localized()
                        return
                    }
                    if !self.userNameValid, let account = self.accountTextField.text, account.count > 0  {
                        self.errorStackView.isHidden = false
                        self.errorMessage.text = R.string.localizable.accountValidateError6.key.localized()
                        return
                    }
                    self.errorStackView.isHidden = true
                    return
                }
                self.errorStackView.isHidden = false
                self.errorMessage.text = R.string.localizable.passwordValidateError3.key.localized()
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        let consistent = Observable.combineLatest(self.passwordTextField.rx.text, self.confirmPasswordTextField.rx.text).map({$0 == $1})
        
        
        let twoPasswordValid = Observable.combineLatest(passwordValid, confirmPasswordValid, consistent).map({ $0 && $1 && $2})
        
//        twoPasswordValid.subscribe(onNext: {[weak self] (validate) in
//            guard let `self` = self else { return }
//
//            if validate {
//                self.confirmPasswordTextField.tailImage = #imageLiteral(resourceName: "check_complete")
//            }
//            else {
//                self.confirmPasswordTextField.tailImage = nil
//            }
//
//
//            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        
        Observable.combineLatest(codeTextField.rx.text.orEmpty.map { $0.count == 4 }, accountTextField.rx.text.orEmpty.map { $0.count > 2 }, twoPasswordValid).subscribe(onNext: {[weak self] (validate) in
            guard let `self` = self else { return }
            
            if self.accountTextField.tailImage != nil && validate.0 && validate.1 && validate.2 {
                self.registerButton.isEnable = true
            }
            else {
                self.registerButton.isEnable = false
            }
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.loginTitle.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
            guard let `self` = self else { return }
            
            self.coordinator?.switchToLogin()
        }).disposed(by: disposeBag)
        
        self.tip.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
            guard let `self` = self else { return }
            
            self.coordinator?.pushCreateTip()
        }).disposed(by: disposeBag)
        
        self.macawView.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
            guard let `self` = self else { return }
            self.updateSvgView()
            
        }).disposed(by: disposeBag)
        
        self.timer = Repeater.every(.seconds(120), {[weak self] (timer) in
            main {
                self?.updateSvgView()
            }
        })
        self.timer?.start()
        
        self.registerButton.rx.tapGesture().when(.recognized).filter {[weak self] (tap) -> Bool in
            guard let `self` = self else { return false }
            
            return self.registerButton.canRepeat
            
            }.subscribe(onNext: {[weak self] (tap) in
                guard let `self` = self else { return }
                
                self.registerButton.canRepeat = false
                
                self.startLoading()
                
                let captcha = self.codeTextField.text ?? ""
                let username = self.accountTextField.text ?? ""
                let password = self.passwordTextField.text ?? ""
                async {
                    let success = try! await(UserManager.shared.register(self.pinID, captcha: captcha, username: username, password: password))
                    
                    DispatchQueue.main.async {
                        self.endLoading()
                        
                        if success.0 {
                            self.coordinator?.confirmRegister(self.passwordTextField.text!)
                        }
                        else {
                            self.updateSvgView()
                            
                            var message = R.string.localizable.registerFail.key.localized()
                            if success.1 == 403 {
                                message = R.string.localizable.registerFail403.key.localized()
                            }
                            else if success.1 == 429 {
                                message = R.string.localizable.registerFail429.key.localized()
                            }
                            self.showAlert(message, buttonTitle: R.string.localizable.ok.key.localized())
                        }
                        self.registerButton.canRepeat = true
                    }
                }
            }).disposed(by: disposeBag)
    }
}

