//
//  UserHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Guitar
import coswift

enum FrequencyType: Int {
    case normal = 0
    case time
    case wiFi

    func description() -> String {
        switch self {
        case .normal: return R.string.localizable.frequency_normal.key
        case .time: return R.string.localizable.frequency_time.key
        case .wiFi: return R.string.localizable.frequency_wifi.key
        }
    }
}

class UserHelper {
    var cachedIdToName: [String: String] = [:]

    static var shared = UserHelper()

    func getName(id: String) -> Promise<String> {
        if let name = cachedIdToName[id] {
            return Promise.init(constructor: { (fulfill, reject) in
                fulfill(name)
            })
        }

        return Promise.init(constructor: { (fulfill, reject) in
            CybexDatabaseApiService.request(target: .getObjects(id: id), success: { (json) in
                if let name = json[0]["name"].string {
                    self.cachedIdToName[id] = name
                    fulfill(name)
                } else {
                    reject(CybexError.tipError(.userNotExist))
                }
            }, error: { (json) in
                reject(CybexError.tipError(.userNotExist))

            }) { (error) in
                reject(CybexError.tipError(.userNotExist))
            }
        })
    }
    
    class func getBalanceFromAssetID(_ assetID: String) -> Decimal {
        if let balance = getBalanceWithAssetId(assetID) {
            return balance.balance.decimal()
        }

        return 0
    }
   
    class func getBalanceWithAssetId(_ asset: String) -> Balance? {
        if let balances = UserManager.shared.fullAccount.value?.balances {
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
