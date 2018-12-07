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
    static let theme = DefaultsKey<Int>("theme")
    static let language = DefaultsKey<String>("language")
    static let refreshTime = DefaultsKey<Double>("refreshTime")
    static let frequencyType = DefaultsKey<Int>("frequency_type")
    static let username = DefaultsKey<String>("com.nbltrust.cybex.username")

    static let transferAddressList = DefaultsKey<[TransferAddress]>("TransferAddressList")
    static let withdrawAddressList = DefaultsKey<[WithdrawAddress]>("WithdrawAddressList")

    static let environment = DefaultsKey<String>("environment")
    
    static let isRealName = DefaultsKey<Bool>("isRealName")
}

extension UserDefaults {
    var isTestEnv : Bool {
        return Defaults[.environment] == "test"
    }
}
