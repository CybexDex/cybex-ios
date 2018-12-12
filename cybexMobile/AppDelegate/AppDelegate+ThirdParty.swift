//
//  AppDelegate+ThirdParty.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Kingfisher
import IQKeyboardManagerSwift

let navigator = Navigator()

extension AppDelegate {
    func setupThirdParty() {
        URLNavigationMap.initialize(navigator: navigator)

        let cache = KingfisherManager.shared.cache
        cache.clearDiskCache()
        cache.clearMemoryCache()
        cache.cleanExpiredDiskCache()

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
}
