//
//  JWTHelpers.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

// A customize JSON decoder to decode from base64URL strings.
class Base64JSONDecoder: JSONDecoder {
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let string = String(data: data, encoding: .ascii) else {
            throw CryptoError.generalError(reason: .dataConversionFailed(data: data, encoding: .ascii))
        }

        return try decode(type, from: string)
    }

    func decode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable {
        guard let decodedData = string.base64URLDecoded else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        return try super.decode(type, from: decodedData)
    }

    func decodeDictionary(_ string: String) throws -> [String: Any] {
        guard let decodedData = string.base64URLDecoded else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        guard let result = try JSONSerialization.jsonObject(with: decodedData) as? [String: Any] else {
            throw CryptoError.generalError(
                reason: .decodingFailed(string: String(data: decodedData, encoding: .utf8)!, type: [String: Any].self))
        }
        return result
    }
}

extension String {
    // Returns the data of self (which is a base64 string), with URL related characters decoded.
    var base64URLDecoded: Data? {
        let paddingLength = 4 - count % 4
        // Filling = for %4 padding.
        let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
        let base64EncodedString = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            + padding
        return Data(base64Encoded: base64EncodedString)
    }
}

extension Data {
    // Encode self with URL escaping considered.
    var base64URLEncoded: String {
        let base64Encoded = base64EncodedString()
        return base64Encoded
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
