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

  override func viewDidLoad() {
    super.viewDidLoad()
    
    configLeftNavButton(#imageLiteral(resourceName: "ic_close_24_px"))
    
    accountTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
    passwordTextField.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo

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
