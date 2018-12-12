//
//  AppDelegate+Log.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftyBeaver
import AlamofireNetworkActivityLogger

let log = SwiftyBeaver.self

extension AppDelegate {
    func setupLog() {
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.level = .error
        let console = ConsoleDestination()
        log.addDestination(console)
    }
}
