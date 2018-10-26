//
//  AccountRootCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class AccountRootCoordinator: NavCoordinator {
  override func start() {
    let vc = R.storyboard.account.accountViewController()!

    let coordinator = AccountCoordinator(rootVC: self.rootVC)
    vc.localizedText = R.string.localizable.accountTitle.key.localizedContainer()

    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}
