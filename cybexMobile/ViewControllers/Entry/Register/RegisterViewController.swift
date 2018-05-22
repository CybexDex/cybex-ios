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
  
  var timer:Repeater?
  
  var pinID:String = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configLeftNavButton(#imageLiteral(resourceName: "ic_close_24_px"))
    setupUI()
    setupEvent()
    
    updateSvgView()
    
    //    let exist = try! await(UserManager.shared.checkUserNameExist("cybex-test"))
    
    //    print("---\(exist)")
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
}

extension RegisterViewController {
  func setupEvent() {
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
      guard let captcha = self.codeTextField.text, let username = self.accountTextField.text, let password = self.passwordTextField.text else {
        self.endLoading()
        
        let vc = UIAlertController(title: "提示", message: "提交信息不足", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
        vc.addAction(action)
        self.presentVC(vc)
        
        return
      }
      
      async {
        let success = try! await(UserManager.shared.register(self.pinID, captcha: captcha, username: username, password: password))
        
        DispatchQueue.main.async {
          self.endLoading()
          
          if success {
            self.coordinator?.dismiss()
          }
          else {
            self.updateSvgView()
            
            let vc = UIAlertController(title: "提示", message: "注册失败", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: nil)
            vc.addAction(action)
            self.presentVC(vc)
            
          }
        }
      }
      
      
    }).disposed(by: disposeBag)
    
  }
}

