//
//  TradeRootCoordinator.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class TradeRootCoordinator: NavCoordinator {
  override func start() {
    let vc = R.storyboard.business.tradeViewController()!
    
    let coordinator = TradeCoordinator(rootVC: self.rootVC)
    vc.localized_text = R.string.localizable.navTrade.key.localizedContainer()
    
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}
