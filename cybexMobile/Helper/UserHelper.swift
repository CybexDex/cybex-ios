//
//  UserHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Guitar

class UserHelper {
    class func getBalanceFromAssetID(_ assetID: String) -> Decimal {
        if let balance = getBalanceWithAssetId(assetID) {
            return balance.balance.decimal()
        }

        return 0
    }
   
    class func getBalanceWithAssetId(_ asset: String) -> Balance? {
        if let balances = UserManager.shared.balances.value {
            for balance in balances {
                if balance.assetType == asset {
                    return balance
                }
            }
            return nil
        }
        return nil
    }

    class func verifyPassword(_ password: String) -> (Bool) {
        if password.count < 12 {
            return false
        }

        let guiter = Guitar(pattern: "(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[^a-zA-Z0-9]).{12,}")
        if !guiter.test(string: password) {
            return false
        } else {
            return true
        }
    }
}
