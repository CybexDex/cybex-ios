//
//  AppDelegate+Start.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import flutter_boost

extension AppDelegate {
    func start() {
        AppConfiguration.shared.appCoordinator.start()

        FlutterBoostPlugin.sharedInstance()?.startFlutter(with: FLBRoute.shared, onStart: { (vc) in
            
        })
    }

}
