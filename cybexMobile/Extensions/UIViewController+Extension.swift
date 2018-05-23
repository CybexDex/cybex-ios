//
//  UIViewController+Extension.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension UIViewController {
  func showAlert(_ message:String, buttonTitle:String) {
    let vc = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.alert)
    let action = UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil)
    vc.addAction(action)
    
    self.present(vc, animated: true, completion: nil)
  }
  
}
