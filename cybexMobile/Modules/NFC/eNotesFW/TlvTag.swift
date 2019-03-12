//
//  TlvTag.swift
//  NFC-Example
//
//  Created by Victor Xu on 2019/2/26.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

import Foundation

public struct TlvTag {
    static let  Device_Certificate = "30"
    static let  Account = "32"
    static let  BlockChain_PublicKey = "55"
    static let  OneTime_PrivateKey = "56"
    static let  OneTime_PublicKey = "57"
    static let  OneTime_Nonce  = "74"
    static let  OneTime_Signature = "75"
    static let  TransactionPinStatus = "94"
    static let  OneTime_SignatureChecksum = "b1"
    static let  OneTime_PrivateKeyChecksum = "b0"
}
