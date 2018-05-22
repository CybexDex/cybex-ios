//
//  PinCodeViewController.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import IHKeyboardAvoiding

class PinCodeViewController: BaseViewController {
  var coordinator: RegisterStateManagerProtocol?

  @IBOutlet weak var pinCodeView: PinCodeView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    self.pinCodeView.data = svg
    self.pinCodeView.textField.becomeFirstResponder()
  }
}
