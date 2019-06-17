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

class FullAccount: HandyJSON {
    var account: Account?
    var balances: [Balance] = []
    var limitOrders: [LimitOrder] = []

    //rmb value
    var limitOrderValue: Decimal = 0
    var limitOrderBuyValue: Decimal = 0
    var limitOrderSellValue: Decimal = 0
    var balance: Decimal = 0

    required init() {}

    func mapping(mapper: HelpingMapper) {
        mapper <<< limitOrders <-- "limit_orders"
    }

    func existMoreActiveKey() -> Bool {
        guard let account = account else { return false }
        return account.activePubKeys.count > 1
    }

    func calculateLimitOrderValue() {
        var decimallimitOrderValue: Decimal = 0
        var decimalBuylimitOrderValue: Decimal = 0
        var decimalSelllimitOrderValue: Decimal = 0

        for limitOrderValue in limitOrders {
            let value = limitOrderValue.rmbValue()
            decimallimitOrderValue += value

            if limitOrderValue.isBuy {
                decimalBuylimitOrderValue += value
            } else {
                decimalSelllimitOrderValue += value
            }
        }

        limitOrderValue = decimallimitOrderValue
        limitOrderBuyValue = decimalBuylimitOrderValue
        limitOrderSellValue = decimalSelllimitOrderValue
    }


    func calculateBalanceValue() {
        var balanceValues: Decimal = 0

        for balanceValue in balances {
            balanceValues += balanceValue.rmbValue()
        }

        balanceValues += limitOrderValue

        balance = balanceValues
    }

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
        mapper <<< activeAuths <-- ["active_keys_auths", "active.key_auths"]
        mapper <<< ownerAuths <-- ["owner_keys_auths", "owner.key_auths"]
        mapper <<< id <-- "id"
        mapper <<< memoKey <-- ["memo_key", "options.memo_key"]
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

    func checkPermission(_ keys: [AccountKeys]) -> AccountPermission {
        var permission = AccountPermission()

        var canUnlock = false

        let allKeys = keys.reduce([], { $0 + $1.pubKeys }).removingDuplicates()

        for key in allKeys {
            if allPubKeys.contains(key) {
                canUnlock = true
                permission.defaultKey = key
            }
        }

        let canTrade = allKeys.contains(where: { (key) -> Bool in
            return activePubKeys.contains(key)
        })

        permission.unlock = canUnlock
        permission.withdraw = allKeys.contains(memoKey)
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
