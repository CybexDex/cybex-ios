//
//  AppDelegate+UserSetting.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability
import SwiftyUserDefaults

extension AppDelegate {
    func setupUserSetting() {
        let name = Defaults[.username]
        if name.count > 0 {
            UserManager.shared.name.accept(name)
        }

        let loginType = Defaults[.loginType]
        if loginType > 0 {
            UserManager.shared.loginType = UserManager.LoginType(rawValue: loginType)!
        }

        if Defaults.hasKey(.frequencyType) {
            UserManager.shared.frequencyType = FrequencyType(rawValue: Defaults[.frequencyType])!
        }

        NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
            guard let reachability = note.object as? Reachability else {
                return
            }

            switch reachability.connection {
            case .wifi, .cellular:
                if UserManager.shared.frequencyType == .normal {
                    UserManager.shared.refreshTime = 6
                } else if UserManager.shared.frequencyType == .time {
                    UserManager.shared.refreshTime = 3
                } else {
                    if reachability.connection == .wifi {
                        UserManager.shared.refreshTime = 3
                    } else {
                        UserManager.shared.refreshTime = 6
                    }
                }
            case .none:

                break
            }

        }
        

    }
}
