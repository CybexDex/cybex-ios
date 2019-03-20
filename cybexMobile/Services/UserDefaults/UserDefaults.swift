//
//  UserDefaults.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/2.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let theme = DefaultsKey<Int>("theme", defaultValue: 0)
    static let language = DefaultsKey<String>("language", defaultValue: "")
    static let refreshTime = DefaultsKey<Double>("refreshTime", defaultValue: 0)
    static let frequencyType = DefaultsKey<Int>("frequency_type", defaultValue: 0)
    static let loginType = DefaultsKey<Int>("logintype", defaultValue: 0)
    static let locktime = DefaultsKey<Int>("locktime", defaultValue: UserManager.LockTime.low.rawValue)
    static let unlockType = DefaultsKey<Int>("unlockType", defaultValue: 0)
    static let pinCodes = DefaultsKey<[String: Any]>("pincodes", defaultValue: [:])

    static let username = DefaultsKey<String>("com.nbltrust.cybex.username", defaultValue: "")
    static let keys = DefaultsKey<String>("com.nbltrust.cybex.keys", defaultValue: "")
    static let enotesKeys = DefaultsKey<String>("com.nbltrust.cybex.enotesKeys", defaultValue: "")
    static let account = DefaultsKey<String>("com.nbltrust.cybex.account", defaultValue: "")

    static let transferAddressList = DefaultsKey<[TransferAddress]>("TransferAddressList", defaultValue: [])
    static let withdrawAddressList = DefaultsKey<[WithdrawAddress]>("WithdrawAddressList", defaultValue: [])

    static let environment = DefaultsKey<String>("environment", defaultValue: "")
    static let showContestTip = DefaultsKey<Bool>("showContestTip", defaultValue: false)

    static let isRealName = DefaultsKey<Bool>("isRealName", defaultValue: false)
    
    static let hasCode = DefaultsKey<Bool>("hasCode", defaultValue: false)
}

extension UserDefaults {
    var isTestEnv : Bool {
        return Defaults[.environment] == "test"
    }
}
