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
    
    configLeftNavButton(#imageLiteral(resourceName: "ic_close_24_px"))
    
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
          let vc = UIAlertController(title: "提示", message: "账号名或者密码错误", preferredStyle: UIAlertControllerStyle.alert)
          let action = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
          vc.addAction(action)
          self.presentVC(vc)
        }
      }
    }).disposed(by: disposeBag)
  }
  
  
}
