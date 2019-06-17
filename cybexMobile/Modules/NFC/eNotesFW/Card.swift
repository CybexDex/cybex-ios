//
//  Card.swift
//  eNotes
//
//  Created by Smiacter on 2018/8/16.
//  Copyright © 2018 Smiacter. All rights reserved.
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
import Foundation
import BigInt
import CryptoSwift
import CommonCrypto
import secp256k1_swift

public struct Card {
    static var secp256k1_N = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!

    //这个key就是acitvePublickKey
    public var blockchainPublicKey = ""
    public var oneTimePrivateKey = ""
    public var oneTimePublicKey = ""
    public var oneTimeNonce: UInt32 = 0
    public var oneTimeSignature = ""

    public var transactionPinStatus = false //是否加密
    public var oneTimeSignatureChecksum: UInt16 = 0
    public var oneTimePrivateKeyChecksum: UInt16 = 0
    public var account: String? = nil

    public var cert = Cert()

    var base58PubKey: String = ""
    var base58OnePubKey: String = ""
    var base58OnePriKey: String = ""
    var compactSign: String = ""

    mutating func marshalCard(_ sign: String, onePubkey: String, onePriKey: String, pubkey: String) {
        base58OnePriKey = onePriKey
        base58OnePubKey = onePubkey
        base58PubKey = pubkey
        compactSign = sign
    }

    func validatorPin(_ pin: String) -> (success: Bool, signature: String, privateKey: String) {
        //需要先用pin码做1次sha256以后调用方法deCrypt3des解密oneTimeSignature得到R和S，然后调用方法toCanonicalised得到最后的S值，调用getRecId得到recId
        let pinSha256 = pin.data(using: .utf8)!.sha256().hexEncodedString()

        let deCodeSignature = Card.deCrypt3des(coding: unhexlify(oneTimeSignature)!, pin: pinSha256)
        let checkSumSignature = Card.crc16(buf: unhexlify(deCodeSignature)!)

        let deCodePrivate = Card.deCrypt3des(coding: unhexlify(oneTimePrivateKey)!, pin: pinSha256)
        let checkSumPrivate = Card.crc16(buf: unhexlify(deCodePrivate)!)

        if checkSumSignature == oneTimeSignatureChecksum, checkSumPrivate == oneTimePrivateKeyChecksum {
            return (true, deCodeSignature, deCodePrivate)
        }
        return (false, "", "")
    }

    func getBlockchainSignature(_ signature: String) -> String? {
        guard let r = signature.substring(from: 0, length: 64),
            let s = signature.substring(from: 64, length: 64) else { return nil }
        let hash = getDataHash(oneTimeNonce, onTimePublicKey: oneTimePublicKey)

        let sign = getSignData(r, s: Card.toCanonicalised(s: s), activePubkey: blockchainPublicKey, hashData: hash)?.hexEncodedString()

        return sign
    }

    func getDataHash(_ oneTimeNonce:UInt32, onTimePublicKey:String) -> Data {
        let pbkey = Data.fromHex(onTimePublicKey)!
        let b = SECP256K1.combineSerializedPublicKeys(keys: [pbkey], outputCompressed: true)!

        let data = oneTimeNonce.littleEndian.data + b

        return data.sha256().sha256()
    }

    func getSignData(_ r: String, s: String, activePubkey: String, compressed: Bool = false, hashData: Data) -> Data? {
        let sig = r + s

        for i in 0...3 {
            guard let signature = unhexlify("\(sig)0\(i)"), signature.count == 65 else { continue }
            let rData = signature[0..<32].bytes
            let sData = signature[32..<64].bytes
            let vData = signature[64]

            guard let signatureData = SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { continue }
            
            guard let publicKey = SECP256K1.recoverPublicKey(hash: hashData, signature: signatureData) else { continue }
            if publicKey.hexEncodedString() == activePubkey {
                let v: UInt8 = UInt8(i) + 27 + (compressed ? 0 : 4)

                return v.data + Data(rData) + Data(sData)
            }
        }
        return nil
    }
}

extension Card {
    static func compressedPublicKey(_ pubKey: String) -> String {
        let pbkey = Data.fromHex(pubKey)!
        let b = SECP256K1.combineSerializedPublicKeys(keys: [pbkey], outputCompressed: true)!
        let encodedPbkey = b.bytes.base58CheckEncodedWithRipmendString
        return "CYB" + encodedPbkey
    }

    static func compressedPrivateKey(_ privateKey: String) -> String {
        var privateKey = Data.fromHex(privateKey)!
        privateKey.insert(0x80, at: 0)
        
        let encodedPvkey = privateKey.bytes.base58CheckEncodedString
        return encodedPvkey
    }

    static func toCanonicalised(s: String) -> String {
        var bnS = BigUInt(s,radix:16)!

        if(bnS > (Card.secp256k1_N >> 1)){
            bnS = Card.secp256k1_N - bnS

            return String(bnS, radix: 16, uppercase: true)
        }

        return s
    }
    
    /*return !(c.data[1] & 0x80)
     && !(c.data[1] == 0 && !(c.data[2] & 0x80))
     && !(c.data[33] & 0x80)
     && !(c.data[33] == 0 && !(c.data[34] & 0x80));*/
    //65
    static func isCanonical(_ data: Data) -> Bool {
        return data[1] & 0x80 == 0
            && !(data[1] == 0 && (data[2] & 0x80 == 0))
            && data[33] & 0x80 == 0
            && !(data[33] == 0 && (data[34] & 0x80 == 0))
    }

    //crc16
    public static func crc16(buf:Data) -> UInt16 {
        var fcs = UInt16(0xffff)
        let len = buf.count
        for i in 0 ..< len{
            var d = UInt16(buf[i])<<8
            for _ in 0 ..< 8{
                if(((fcs^d)&0x8000) != 0){
                    fcs = (fcs << 1) ^ 0x1021
                }else{
                    fcs <<= 1
                }
                d <<= 1
            }
        }
        return UInt16(~fcs)
    }

    //3des 加密
    public static func enCrypt3des(_ data:Data , pin:String) -> String {
        let key = (pin as NSString).substring(to: 48)
        let iv = (pin as NSString).substring(with: NSMakeRange(48, 16))
        let ivData = unhexlify(iv)!
        let ivPoint = UnsafeRawPointer((ivData as NSData).bytes)
        // TODO: 创建要加密或解密的数据接受对象


        // 创建数据编码后的指针
        let dataPointer = UnsafeRawPointer((data as NSData).bytes)
        // 获取转码后数据的长度
        let dataLength = size_t(data.count)

        // TODO: 将加密或解密的密钥转化为Data数据
        let keyData = unhexlify(key)!
        // 创建密钥的指针
        let keyPointer = UnsafeRawPointer(keyData.bytes)
        // 设置密钥的长度
        let keyLength = size_t(kCCKeySize3DES)

        // TODO: 创建加密或解密后的数据对象
        let cryptData = NSMutableData(length: Int(dataLength) + kCCBlockSize3DES)
        // 获取返回数据(cryptData)的指针
        let cryptPointer = UnsafeMutableRawPointer(mutating: cryptData!.mutableBytes)
        // 获取接收数据的长度
        let cryptDataLength = size_t(cryptData!.length)
        // 加密或则解密后的数据长度
        var cryptBytesLength:size_t = 0

        // TODO: 数据参数的准备
        // 是解密或者加密操作(CCOperation 是32位的)
        let operation:CCOperation = UInt32(kCCEncrypt)
        // 算法的类型
        let algorithm:CCAlgorithm = UInt32(kCCAlgorithm3DES)
        // 设置密码的填充规则（ PKCS7 & ECB 两种填充规则）
        let options:CCOptions = UInt32(0)
        // 执行算法处理
        let cryptStatue = CCCrypt(operation, algorithm, options, keyPointer, keyLength,ivPoint, dataPointer, dataLength, cryptPointer, cryptDataLength, &cryptBytesLength)
        // 通过返回状态判断加密或者解密是否成功
        if  UInt32(cryptStatue) == kCCSuccess  {
            // 加密
            cryptData!.length = cryptBytesLength
            // 返回3des加密对象
            let cryData = Data(referencing: cryptData!)
            return cryData.hexEncodedString()

            //                return cryptData!.base64EncodedString(options: .lineLength64Characters)
        }
        // 3des 加密或者解密不成功
        return " 3des Encrypt or Decrypt is faill"


    }

    //3des 解密
    public static func deCrypt3des(coding  data:Data , pin:String) -> String{
        let key = (pin as NSString).substring(to: 48)
        let iv = (pin as NSString).substring(with: NSMakeRange(48, 16))
        let ivData = unhexlify(iv)!
        let ivPoint = UnsafeRawPointer((ivData as NSData).bytes)
        // TODO: 创建要加密或解密的数据接受对象


        // 创建数据编码后的指针
        let dataPointer = UnsafeRawPointer((data as NSData).bytes)
        // 获取转码后数据的长度
        let dataLength = size_t(data.count)

        // TODO: 将加密或解密的密钥转化为Data数据
        let keyData = unhexlify(key)!
        // 创建密钥的指针
        let keyPointer = UnsafeRawPointer(keyData.bytes)
        // 设置密钥的长度
        let keyLength = size_t(kCCKeySize3DES)

        // TODO: 创建加密或解密后的数据对象
        let cryptData = NSMutableData(length: Int(dataLength) )
        // 获取返回数据(cryptData)的指针
        let cryptPointer = UnsafeMutableRawPointer(mutating: cryptData!.mutableBytes)
        // 获取接收数据的长度
        let cryptDataLength = size_t(cryptData!.length)
        // 加密或则解密后的数据长度
        var cryptBytesLength:size_t = 0

        // TODO: 数据参数的准备
        // 是解密或者加密操作(CCOperation 是32位的)
        let operation:CCOperation = UInt32(kCCDecrypt)
        // 算法的类型
        let algorithm:CCAlgorithm = UInt32(kCCAlgorithm3DES)
        // 设置密码的填充规则（ PKCS7 & ECB 两种填充规则）
        let options:CCOptions = UInt32(0)
        // 执行算法处理
        let cryptStatue = CCCrypt(operation, algorithm, options, keyPointer, keyLength,ivPoint, dataPointer, dataLength, cryptPointer, cryptDataLength, &cryptBytesLength)
        // 通过返回状态判断加密或者解密是否成功
        if  UInt32(cryptStatue) == kCCSuccess  {
            // 加密
            cryptData!.length = cryptBytesLength
            // 返回3des加密对象
            let cryData = Data(referencing: cryptData!)
            return cryData.hexEncodedString()

            //                return cryptData!.base64EncodedString(options: .lineLength64Characters)
        }
        // 3des 加密或者解密不成功
        return " 3des Encrypt or Decrypt is faill"


    }
}
