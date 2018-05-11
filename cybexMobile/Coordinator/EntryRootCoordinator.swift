//
//  EntryRootCoordinator.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class EntryRootCoordinator: NavCoordinator {
  override func start() {
    let vc = R.storyboard.main.entryViewController()!
    
    let coordinator = EntryCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}
