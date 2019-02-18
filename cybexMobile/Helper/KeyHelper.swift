//
//  KeyHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2019/2/15.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation

class KeyHelper {
    class func getPubKeyFrom(_ address: String, account: AccountKeys) -> String? {
        for key in account.keys {
            if key.addresses.contains(address) {
                return key.publicKey
            }
        }

        return nil
    }
}
