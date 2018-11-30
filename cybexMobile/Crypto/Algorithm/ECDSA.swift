//
//  ECDSA.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import CommonCrypto

/// Namespace for ECDRA related things.
struct ECDSA {}

/// ECDRA Digest Algorithms.
extension ECDSA {
    enum Curve: String, Decodable {
        case p256 = "P-256"
        case p384 = "P-384"
        case p521 = "P-521"

        var signatureOctetLength: Int {
            return coordinateOctetLength * 2
        }

        // Standards for Efficient Cryptography Group SEC 1:
        // Elliptic Curve Cryptography
        // http://www.secg.org/sec1-v2.pdf
        var coordinateOctetLength: Int {
            switch self {
            case .p256:
                return 32
            case .p384:
                return 48
            case .p521:
                return 66
            }
        }
    }

    enum Algorithm: CryptoAlgorithm {
        case sha1, sha224, sha256, sha384, sha512

        var length: CC_LONG {
            switch self {
            case .sha1:   return CC_LONG(CC_SHA1_DIGEST_LENGTH)
            case .sha224: return CC_LONG(CC_SHA224_DIGEST_LENGTH)
            case .sha256: return CC_LONG(CC_SHA256_DIGEST_LENGTH)
            case .sha384: return CC_LONG(CC_SHA384_DIGEST_LENGTH)
            case .sha512: return CC_LONG(CC_SHA512_DIGEST_LENGTH)
            }
        }

        var signatureAlgorithm: SecKeyAlgorithm {
            switch self {
            case .sha1:   return .ecdsaSignatureMessageX962SHA1
            case .sha224: return .ecdsaSignatureMessageX962SHA224
            case .sha256: return .ecdsaSignatureMessageX962SHA256
            case .sha384: return .ecdsaSignatureMessageX962SHA384
            case .sha512: return .ecdsaSignatureMessageX962SHA512
            }
        }

        var encryptionAlgorithm: SecKeyAlgorithm {
            Log.fatalError("ECDSA should be only used for signing purpose.")
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

        var curve: Curve {
            switch self {
            case .sha1, .sha224: Log.fatalError("Too simple SHA algorithm. Not supported.")
            case .sha256: return .p256
            case .sha384: return .p384
            case .sha512: return .p521
            }
        }
    }
}
