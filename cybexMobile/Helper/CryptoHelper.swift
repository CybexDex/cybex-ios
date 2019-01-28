//
//  CryptoHelper.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/18.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON

class CryptoHelper {
    class func compressTransaction(_ jsonstr: String,
                                   timeInterval: Double,
                                   from: Int,
                                   to: Int,
                                   assetId: Int,
                                   amount: Int) -> String {
        let json = JSON(parseJSON: jsonstr)
        var packedData = pack("<4iqd", [from,
                                        to,
                                        assetId,
                                        Int(json["ref_block_num"].stringValue.int32),
                                        amount,
                                        timeInterval])

        guard let bid = unhexlify(json["ref_block_prefix"].stringValue),
            let signedstr = json["signatures"].arrayValue.first,
            let unhexSignedStr = unhexlify(signedstr.stringValue)
            else {
                return ""
        }

        packedData.append(bid)
        packedData.append(unhexSignedStr)

        let result = packedData.base64EncodedString()

        return result
    }
}
