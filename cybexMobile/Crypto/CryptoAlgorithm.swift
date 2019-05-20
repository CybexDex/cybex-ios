//
//  CryptoAlgorithm.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import CommonCrypto

typealias CryptoDigest = (
    _ data: UnsafeRawPointer?,
    _ length: CC_LONG,
    _ md: UnsafeMutablePointer<UInt8>?) -> UnsafeMutablePointer<UInt8>?

/// Represents an algorithm used in crypto.
protocol CryptoAlgorithm {
    var length: CC_LONG { get }
    var signatureAlgorithm: SecKeyAlgorithm { get }
    var encryptionAlgorithm: SecKeyAlgorithm { get }
    var digest: CryptoDigest { get }
}

extension Data {

    /// Calculate the digest with a given algorithm.
    ///
    /// - Parameter algorithm: The algorithm be used. It should provice a digest hash method at least.
    /// - Returns: The digest data.
    func digest(using algorithm: CryptoAlgorithm) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(algorithm.length))
        withUnsafeBytes { _ = algorithm.digest($0, CC_LONG(count), &hash) }
        return Data(hash)
    }
}
