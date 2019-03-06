//
//  CertificateParser.swift
//  eNotesSdk
//
//  Created by Smiacter on 2018/10/8.
//  Copyright © 2018 eNotes. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// Parse certificate to humanity model

class CertificateParser: NSObject {

    private var decoder: X509Certificate?
    private var tbsCertificateAndSig :Data!
    private var tbsCertificate :Data!
    private var version: Int = -1
    private var r = ""
    private var s = ""
    /// vendorName
    private var issuer = ""
    /// productionDate
    private var issueTime = Date()
    /// face value
    private var deno: Int = -1
    /// cornType, btc:80000000 eth:8000003c
    private var blockchain = ""
    /// network, MainBtc:0 TestBtc:1 Ethereum:1 EthereumRopsten:3 EthereumRinkeby:4 EthereumKovan:42
    private var network: Int = -1
    /// contract address of ERC20 token
    private var contract: String?
    private var publicKeyInformation = ""
    private var serialNumber = ""
    private var manufactureBatch = ""
    private var manufactureTime = Date()
    
    init?(hexCert: String) {
        guard let data = Data(base64Encoded: hexCert) else {
            return nil
        }
        do {
            try decoder = X509Certificate(data: data)
            guard decoder != nil else {
                return
            }
            tbsCertificateAndSig=decoder!.tbsCertificateData
            tbsCertificate=decoder!.tbsCertificate.rawValue
            version = decoder!.version
            issuer = decoder!.issuer
            issueTime = decoder!.issueTime
            deno = decoder!.deno
            blockchain = decoder!.blockchain
            network = decoder!.network
            contract = decoder!.contract
            publicKeyInformation = decoder!.publicKeyInformation
            serialNumber = decoder!.serialNumber
            manufactureBatch = decoder!.manufactureBatch
            manufactureTime = decoder!.manufactureTime
            r = decoder!.r
            s = decoder!.s
        } catch  {
            return nil
        }
    }
    
    /// Convert to Card which contain all card info, it will be used anywhere
    func toCert() -> Cert {
        var card = Cert()
        card.tbsCertificateAndSig = tbsCertificateAndSig
        card.tbsCertificate = tbsCertificate
        card.issuer = issuer
        card.issueTime = issueTime
        card.deno = deno
        card.contract = contract
        if let contract = contract, contract.isEmpty {
            card.contract = nil
        }
        card.publicKey = publicKeyInformation
        card.serialNumber = serialNumber
        card.manufactureBatch = manufactureBatch
        card.manufactureTime = manufactureTime
        card.r = r
        card.s = s
        
        return card
    }
    
    
}
