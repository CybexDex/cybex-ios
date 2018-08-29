//
//  File.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class ETORootCoordinator : NavCoordinator {
    override func start() {
        let vc = R.storyboard.etoDetail.etoDetailViewController()!
        let coordinator = ETODetailCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }
}
