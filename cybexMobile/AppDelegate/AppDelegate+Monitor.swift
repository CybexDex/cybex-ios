//
//  AppDelegate+Monitor.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability

let reachability = Reachability()!

extension AppDelegate {
    func monitorNetwork() {
        ZYNetworkAccessibity.setAlertEnable(true)
        ZYNetworkAccessibity.setStateDidUpdateNotifier { (state) in
            if state == ZYNetworkAccessibleState.accessible {
                NotificationCenter.default.post(name: .NetWorkChanged, object: nil)
            }
        }
        ZYNetworkAccessibity.start()

        try? reachability.startNotifier()
    }


}
