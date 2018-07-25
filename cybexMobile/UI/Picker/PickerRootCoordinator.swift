//
//  PickerRootCoordinator.swift
//  cybexMobile
//
//  Created by peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class PickerRootCoordinator: NavCoordinator {
  override func start() {
    
  }
  
  func startWithItems(_ items: AnyObject, selectedValue: (component: NSInteger,row: NSInteger)) {
    if let vc = R.storyboard.components.pickerViewController() {
      vc.items = items
      vc.selectedValue = selectedValue
      let coordinator = PickerCoordinator(rootVC: self.rootVC)
      vc.coordinator = coordinator
      
      self.rootVC.pushViewController(vc, animated: true)
    }
  }
}
