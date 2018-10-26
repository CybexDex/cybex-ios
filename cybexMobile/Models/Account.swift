//
//  Account.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class Account: Mappable {
    var membershipExpirationDate: String = ""
    var name: String = ""
    var activeAuths: [Any] = []
    var ownerAuths: [Any] = []
    var memoKey: String = ""
    var id: String = ""

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        membershipExpirationDate    <- (map["membership_expiration_date"], ToStringTransform())
        name                   <- (map["name"], ToStringTransform())
        activeAuths <- map["active.key_auths"]
        ownerAuths <- map["owner.key_auths"]
        id           <- map["id"]
        memoKey  <- map["options.memo_key"]
    }
}

extension Account {
    var superMember: Bool {
        let second = membershipExpirationDate.dateFromISO8601?.timeIntervalSince1970 ?? 1

        return second < 0
    }
}
