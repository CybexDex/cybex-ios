//
//  Crypto.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

class AccountKeys: HandyJSON {
    var activeKey: Key?
    var ownerKey: Key?
    var memoKey: Key?

    var pubKeys: [String] {
        guard let activeKey = activeKey, let memoKey = memoKey, let ownKey = ownerKey else {
            return []
        }

        return [memoKey.publicKey, ownKey.publicKey, activeKey.publicKey]
    }

    var keys: [Key] {
        guard let activeKey = activeKey, let memoKey = memoKey, let ownKey = ownerKey else {
            return []
        }

        return [memoKey, ownKey, activeKey]
    }

    required init() {

    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< activeKey <-- "active-key"
        mapper <<< ownerKey <-- "owner-key"
        mapper <<< memoKey <-- "memo-key"
    }
}

class Key: HandyJSON {
    var privateKey = ""
    var publicKey = ""
    var address = ""
    var compressed = ""
    var uncompressed = ""

    var addresses: [String] {
        return [address, compressed, uncompressed]
    }

    required init() {
    }

    func mapping(mapper: HelpingMapper) {
        mapper <<< privateKey <-- "private_key"
        mapper <<< publicKey <-- "public_key"
        mapper <<< address <-- "address"
        mapper <<< compressed <-- "compressed"
        mapper <<< uncompressed <-- "uncompressed"
    }
}
