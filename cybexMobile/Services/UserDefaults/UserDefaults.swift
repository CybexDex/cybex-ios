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
    var theme : DefaultsKey<Int> { .init("theme", defaultValue: 0) }
    var language : DefaultsKey<String> { .init("language", defaultValue: "") }
    var refreshTime : DefaultsKey<Double> {.init("refreshTime", defaultValue: 0)}
    var frequencyType : DefaultsKey<Int> {.init("frequency_type", defaultValue: 0)}
    var loginType : DefaultsKey<Int>{.init("logintype", defaultValue: 0)}
    var locktime : DefaultsKey<Int>{.init("locktime", defaultValue: UserManager.LockTime.low.rawValue)}
    var unlockType : DefaultsKey<Int>{.init("unlockType", defaultValue: 0)}
    var pinCodes : DefaultsKey<[String: Any]>{.init("pincodes", defaultValue: [:])}

    var username : DefaultsKey<String>{.init("com.nbltrust.cybex.username", defaultValue: "")}
    var keys : DefaultsKey<String>{.init("com.nbltrust.cybex.keys", defaultValue: "")}
    var enotesKeys : DefaultsKey<String>{.init("com.nbltrust.cybex.enotesKeys", defaultValue: "")}
    var account : DefaultsKey<String>{.init("com.nbltrust.cybex.account", defaultValue: "")}

    var transferAddressList : DefaultsKey<[TransferAddress]>{.init("TransferAddressList", defaultValue: [])}
    var withdrawAddressList : DefaultsKey<[WithdrawAddress]>{.init("WithdrawAddressList", defaultValue: [])}

    var environment : DefaultsKey<String>{.init("environment", defaultValue: "product")}
    var showContestTip : DefaultsKey<Bool>{.init("showContestTip", defaultValue: false)}

    var isRealName : DefaultsKey<Bool>{.init("isRealName", defaultValue: false)}

        var hasCode : DefaultsKey<Bool>{.init("hasCode", defaultValue: false)}
}
