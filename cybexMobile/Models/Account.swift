//
//  Account.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct AccountPermission: HandyJSON {
    var unlock: Bool = false
    var defaultKey: String = ""
    var withdraw: Bool = false
    var trade: Bool = false
}

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

    var activePubKeys: [String] {
        guard let auths = activeAuths as? [[Any]] else { return [] }
        guard let mapsResult = auths.map({$0[0]}) as? [String] else { return [] }

        return mapsResult
    }

    var ownerPubKeys: [String] {
        guard let auths = ownerAuths as? [[Any]] else { return [] }
        guard let mapsResult = auths.map({$0[0]}) as? [String] else { return [] }

        return mapsResult
    }

    var allPubKeys: [String] {
        return activePubKeys + ownerPubKeys
    }

    func checkPermission(_ keys: AccountKeys) -> AccountPermission {
        var permission = AccountPermission()

        let canUnlock = keys.pubKeys.contains(where: { (key) -> Bool in
            permission.defaultKey = key
            return allPubKeys.contains(key)
        })

        let canTrade = keys.pubKeys.contains(where: { (key) -> Bool in
            return activePubKeys.contains(key)
        })

        permission.unlock = canUnlock
        permission.withdraw = keys.pubKeys.contains(memoKey)
        permission.trade = canTrade

        return permission
    }
}

extension Account {
    var superMember: Bool {
        let second = membershipExpirationDate.dateFromISO8601?.timeIntervalSince1970 ?? 1

        return second < 0
    }
}
