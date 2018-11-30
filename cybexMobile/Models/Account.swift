//
//  Account.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class Account: HandyJSON {
    var membershipExpirationDate: String = ""
    var name: String = ""
    var activeAuths: [Any] = []
    var ownerAuths: [Any] = []
    var memoKey: String = ""
    var id: String = ""

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<<
            membershipExpirationDate <-- ("membership_expiration_date", ToStringTransform())
        mapper <<< name <-- ("name", ToStringTransform())
        mapper <<< activeAuths <-- "active.key_auths"
        mapper <<< ownerAuths <-- "owner.key_auths"
        mapper <<< id <-- "id"
        mapper <<< memoKey <-- "options.memo_key"
    }
}

extension Account {
    var superMember: Bool {
        let second = membershipExpirationDate.dateFromISO8601?.timeIntervalSince1970 ?? 1

        return second < 0
    }
}
