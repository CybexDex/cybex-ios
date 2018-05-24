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

class RegisterViewController: BaseViewController {
  
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
  @IBOutlet weak var errorMessage: UILabel!
  
  var timer:Repeater?
  
  var pinID:String = ""
  var userNameValid = false {
    didSet {
      if userNameValid , let password = self.passwordTextField.text, password.length > 11 , self.passwordTextField.text == self.confirmPasswordTextField.text, let code = self.codeTextField.text, code.length == 4 {
        self.registerButton.isEnable = true
      }
      else {
        self.registerButton.isEnable = false
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configLeftNavButton(#imageLiteral(resourceName: "ic_close_24_px"))
    setupUI()
    setupEvent()
    
    updateSvgView()
    
  }
  
  func updateSvgView() {
    async {
      let data = try! await(SimpleHTTPService.requestPinCode())
      
      main {
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
  }
  
  @objc override func leftAction(_ sender: UIButton) {
    coordinator?.dismiss()
  }
  
  func commonObserveState() {
    coordinator?.subscribe(errorSubscriber) { sub in
      return sub.select { state in state.errorMessage }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
    
    coordinator?.subscribe(loadingSubscriber) { sub in
      return sub.select { state in state.isLoading }.skipRepeats({ (old, new) -> Bool in
        return false
      })
    }
  }
  
  override func configureObserveState() {
    commonObserveState()
    
  }
  
  deinit {
    self.timer?.pause()
    self.timer = nil
  }
}

extension RegisterViewController {
  func setupEvent() {
    NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidChange, object: accountTextField, queue: nil) {[weak self] (notifi) in
      self?.errorStackView.isHidden = true
      self?.accountTextField.activityView?.isHidden = true
      self?.accountTextField.tailImage = nil
      self?.userNameValid = false
      
      guard let name = self?.accountTextField.text, name.count > 0 else {
        self?.errorStackView.isHidden = true
        return
      }
      
      let (passed, message) = UserManager.shared.validateUserName(name)
      
      if !passed {
        self?.errorStackView.isHidden = false
        self?.errorMessage.text = message
      }
      else {
        self?.errorStackView.isHidden = true
        
        self?.accountTextField.activityView?.isHidden = false
        UserManager.shared.checkUserName(name).done({ (exist) in
          main {
            self?.accountTextField.activityView?.isHidden = true
            if !exist {
              self?.accountTextField.tailImage = #imageLiteral(resourceName: "check_complete")
              self?.userNameValid = true
            }
            else {
              self?.errorStackView.isHidden = false
              self?.errorMessage.text = R.string.localizable.accountValidateError1.key.localized()
            }
          }
        }).cauterize()
      }
    }
    
    let passwordValid = self.passwordTextField.rx.text.orEmpty.map({ $0.count > 11}).share(replay: 1)
    let confirmPasswordValid = self.confirmPasswordTextField.rx.text.orEmpty.map({ $0.count > 11}).share(replay: 1)
    
    passwordValid.subscribe(onNext: {[weak self] (validate) in
      guard let `self` = self else { return }
      
      if validate {
        self.passwordTextField.tailImage = #imageLiteral(resourceName: "check_complete")
        if self.userNameValid {
          self.errorStackView.isHidden = true
        }
      }
      else {
        if self.userNameValid {
          self.errorStackView.isHidden = false
          self.errorMessage.text = R.string.localizable.passwordValidateError1.key.localized()
        }
        
        self.passwordTextField.tailImage = nil
      }
      
      if let confirmText = self.confirmPasswordTextField.text, confirmText.length > 0 && (self.passwordTextField.text != self.confirmPasswordTextField.text) {
        if self.userNameValid {
          self.errorStackView.isHidden = false
          self.errorMessage.text = R.string.localizable.passwordValidateError2.key.localized()
        }
      }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    confirmPasswordValid.subscribe(onNext: {[weak self] (validate) in
      guard let `self` = self else { return }
      
      if !validate {
        self.confirmPasswordTextField.tailImage = nil
      }
      if self.passwordTextField.text == self.confirmPasswordTextField.text {
        if self.userNameValid ,let passwordText = self.passwordTextField.text, passwordText.length > 11 {
          self.errorStackView.isHidden = true
        }
      }
      else {
        if self.userNameValid {
          self.errorStackView.isHidden = false
          if let passwordText = self.passwordTextField.text, passwordText.length > 11 {
            self.errorMessage.text = R.string.localizable.passwordValidateError2.key.localized()
          }
          else {
            
          }
        }
      }
      
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    let consistent = Observable.combineLatest(self.passwordTextField.rx.text, self.confirmPasswordTextField.rx.text).map({$0 == $1})
    
    
    let twoPasswordValid = Observable.combineLatest(passwordValid, confirmPasswordValid, consistent).map({ $0 && $1 && $2})
    
    twoPasswordValid.subscribe(onNext: {[weak self] (validate) in
      guard let `self` = self else { return }
      
      if validate {
        self.confirmPasswordTextField.tailImage = #imageLiteral(resourceName: "check_complete")
      }
      else {
        self.confirmPasswordTextField.tailImage = nil
      }
      
      
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    
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
      self?.updateSvgView()
    })
    self.timer?.start()
    
    self.registerButton.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] (tap) in
      guard let `self` = self else { return }
      
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
            
            self.showAlert(R.string.localizable.registerFail.key.localized(), buttonTitle: R.string.localizable.ok.key.localized())
          }
        }
      }
      
      
    }).disposed(by: disposeBag)
    
  }
}

