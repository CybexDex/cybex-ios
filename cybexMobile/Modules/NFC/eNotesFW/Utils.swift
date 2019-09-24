//
//  Utils.swift
//  NFC-Example
//
//  Created by Victor Xu on 2019/2/26.
//  Copyright © 2019 Hans Knoechel. All rights reserved.
//

import Foundation
import CoreNFC
import CommonCrypto

@available(iOS 11.0, *)
public class Utils {
    
    public static func parseNDEFMessage(messages: [NFCNDEFMessage]) -> Card? {
        for message in messages {
            if(message.records.count >= 3){
                let re = message.records[2]
                return parseNDEFData(data: re.payload)
            }
        }
        return nil
    }
    
    public static func parseNDEFData(data:Data) -> Card? {
        var card = Card()
        let tlv = Tlv.decode(data: data)

        guard let blockchainPublicKey = tlv[Data(hex: TlvTag.BlockChain_PublicKey)],
            let oneTimePrivateKeyData = tlv[Data(hex: TlvTag.OneTime_PrivateKey)],
            let oneTimePublicKey = tlv[Data(hex: TlvTag.OneTime_PublicKey)],
            let oneTimeNonce = tlv[Data(hex: TlvTag.OneTime_Nonce)],
            let oneTimeSignatureData = tlv[Data(hex: TlvTag.OneTime_Signature)],
            let transactionPinStatus = tlv[Data(hex: TlvTag.TransactionPinStatus)],
            let oneTimeSignatureChecksumData = tlv[Data(hex: TlvTag.OneTime_SignatureChecksum)],
            let oneTimePrivateKeyChecksumData = tlv[Data(hex: TlvTag.OneTime_PrivateKeyChecksum)],
            let certificate = tlv[Data(hex: TlvTag.Device_Certificate)] else {
            return nil
        }

        let parser = CertificateParser(hexCert: certificate.toBase64String())!

        card.blockchainPublicKey = blockchainPublicKey.hexEncodedString()
        card.oneTimePrivateKey = oneTimePrivateKeyData.hexEncodedString()
        card.oneTimePublicKey = oneTimePublicKey.hexEncodedString()
        card.oneTimeNonce = oneTimeNonce.toInt32Value()!
        card.oneTimeSignature = oneTimeSignatureData.hexEncodedString()
        card.oneTimeSignatureChecksum = oneTimeSignatureChecksumData.toInt16Value()!
        card.oneTimePrivateKeyChecksum = oneTimePrivateKeyChecksumData.toInt16Value()!
        card.transactionPinStatus = transactionPinStatus.toInt()! != 0
        if let accountData = tlv[Data(hex: TlvTag.Account)] {
            card.account = String(decoding: accountData, as: UTF8.self)
        }
        card.cert = parser.toCert()

        return card
    }
}
