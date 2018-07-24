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
    if let vc = R.storyboard.components.pickerViewController() {
      let coordinator = PickerCoordinator(rootVC: self.rootVC)
      vc.coordinator = coordinator
      self.rootVC.pushViewController(vc, animated: true)
    }

  }
}
