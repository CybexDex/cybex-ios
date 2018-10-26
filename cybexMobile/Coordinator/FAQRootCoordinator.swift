//
//  FAQRootCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class FAQRootCoordinator: NavCoordinator {
  override func start() {
    let vc = R.storyboard.main.faqViewController()!
    vc.localizedText = R.string.localizable.navApply.key.localizedContainer()

    let faqCoordinator = FAQCoordinator(rootVC: self.rootVC)
    vc.coordinator = faqCoordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}
