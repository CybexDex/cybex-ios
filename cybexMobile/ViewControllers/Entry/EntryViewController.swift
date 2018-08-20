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

class EntryViewController: BaseViewController {

  var coordinator: (EntryCoordinatorProtocol & EntryStateManagerProtocol)?

  @IBOutlet weak var accountTextField: ImageTextField!
  @IBOutlet weak var passwordTextField: ImageTextField!
  
  @IBOutlet weak var createTitle: UILabel!
  @IBOutlet weak var loginButton: Button!
    
  override func viewDidLoad() {
    super.viewDidLoad()
        
    setupUI()
    setupEvent()
  }

  func setupUI() {
    accountTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
    passwordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
    accountTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
    passwordTextField.bottomColor = ThemeManager.currentThemeIndex == 0 ? .dark : .paleGrey
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
}

extension EntryViewController {
  func setupEvent() {
    let accountValid = accountTextField.rx.text.orEmpty.map { $0.count > 0 }.share(replay: 1)
    
    let passwordValid = passwordTextField.rx.text.orEmpty.map { $0.count > 0}.share(replay: 1)
    
    Observable.combineLatest(accountValid, passwordValid) {
      return $0 && $1
    }.bind {[weak self] (valid) in
      guard let `self` = self else { return }

      if valid {
        self.loginButton.isEnable = true
      }
      else {
        self.loginButton.isEnable = false
      }
    }.disposed(by: disposeBag)
    
    self.createTitle.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      
      self.coordinator?.switchToRegister()
    }).disposed(by: disposeBag)
    
    self.loginButton.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      
      self.startLoading()
      UserManager.shared.login(self.accountTextField.text!, password: self.passwordTextField.text!) { success in
        self.endLoading()
        if success {
          self.coordinator?.dismiss()
        }
        else {
         self.showAlert(R.string.localizable.accountNonMatch.key.localized(), buttonTitle: R.string.localizable.ok.key.localized())
        }
      }
    }).disposed(by: disposeBag)
  }
  
  
}
