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
        if let vc = R.storyboard.comprehensive.comprehensiveViewController() {
            let coordinator = ComprehensiveCoordinator(rootVC: self.rootVC)
            vc.coordinator = coordinator
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}
