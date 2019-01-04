//
//  AppDelegate+Log.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityLogger

extension AppDelegate {
    func setupLog() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .error
    }
}
