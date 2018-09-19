//
//  Comprehensive.swift
//  cybexMobile
//
//  Created by DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class ComprehensiveRootCoordinator: NavCoordinator {
    override func start() {
        let vc = R.storyboard.account.accountViewController()!
        
        let coordinator = ComprehensiveCoordinator(rootVC: self.rootVC)
        vc.localized_text = R.string.localizable.accountTitle.key.localizedContainer()
        
        // vc.coordinator = coordinat as! (AccountCoordinatorProtocol & AccountStateManagerProtocol)or
        self.rootVC.pushViewController(vc, animated: true)
    }
}
