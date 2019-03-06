//
//  Cert.swift
//  NFC-Example
//
//  Created by Victor Xu on 2019/2/26.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

import Foundation

public struct Cert{
    // readed card info by asn1 decoder
    public var tbsCertificateAndSig = Data()
    public var tbsCertificate = Data()
    public var issuer = ""
    public var issueTime = Date()
    public var deno = 0
    public var contract: String?
    public var publicKey = ""
    public var serialNumber = ""
    public var manufactureBatch = ""
    public var manufactureTime = Date()
    public var r = ""
    public var s = ""
    // custom info
    public var address = ""
    public var isSafe = true
    public var publicKeyData: Data?
    // ERC20 token info
    public var name: String?
    public var symbol: String?
    public var decimals = 0
}
