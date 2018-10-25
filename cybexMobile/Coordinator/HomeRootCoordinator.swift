//
//  HomeRootCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class HomeRootCoordinator: NavCoordinator {
  override func start() {
    let vc = R.storyboard.main.homeViewController()!

    let homeCoordinator = HomeCoordinator(rootVC: self.rootVC)
    vc.coordinator = homeCoordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}
