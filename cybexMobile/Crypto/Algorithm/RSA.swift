//
//  RSA.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import CommonCrypto

/// Namespace for RSA related things.
struct RSA {}

/// RSA Digest Algorithms.
extension RSA {
    enum Algorithm: CryptoAlgorithm {
        case sha1, sha224, sha256, sha384, sha512

        var length: CC_LONG {
            switch self {
            case .sha1: return CC_LONG(CC_SHA1_DIGEST_LENGTH)
            case .sha224: return CC_LONG(CC_SHA224_DIGEST_LENGTH)
            case .sha256: return CC_LONG(CC_SHA256_DIGEST_LENGTH)
            case .sha384: return CC_LONG(CC_SHA384_DIGEST_LENGTH)
            case .sha512: return CC_LONG(CC_SHA512_DIGEST_LENGTH)
            }
        }

        var signatureAlgorithm: SecKeyAlgorithm {
            switch self {
            case .sha1:   return .rsaSignatureMessagePKCS1v15SHA1
            case .sha224: return .rsaSignatureMessagePKCS1v15SHA224
            case .sha256: return .rsaSignatureMessagePKCS1v15SHA256
            case .sha384: return .rsaSignatureMessagePKCS1v15SHA384
            case .sha512: return .rsaSignatureMessagePKCS1v15SHA512
            }
        }

        var encryptionAlgorithm: SecKeyAlgorithm {
            switch self {
            case .sha1:   return .rsaEncryptionOAEPSHA1AESGCM
            case .sha224: return .rsaEncryptionOAEPSHA224AESGCM
            case .sha256: return .rsaEncryptionOAEPSHA256AESGCM
            case .sha384: return .rsaEncryptionOAEPSHA384AESGCM
            case .sha512: return .rsaEncryptionOAEPSHA512AESGCM
            }
        }

        var digest: CryptoDigest {
            switch self {
            case .sha1:   return CC_SHA1
            case .sha224: return CC_SHA224
            case .sha256: return CC_SHA256
            case .sha384: return CC_SHA384
            case .sha512: return CC_SHA512
            }
        }
    }
}
