//
//  JWK.swift
//  cybexMobile
//
//  Created by koofrank on 2018/11/21.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

struct JWK: Decodable {

    typealias Parameters = JWA.KeyParameters

    enum KeyType: String, Decodable {
        case rsa = "RSA"
        case ec = "EC"
    }

    enum PublicKeyUse: String, Decodable {
        case signature = "sig"
        case encryption = "enc"
    }

    enum CodingKeys: String, CodingKey {
        case keyType = "kty"
        case keyUse = "use"
        case keyID = "kid"
    }

    let keyType: KeyType
    let keyUse: PublicKeyUse?
    let keyID: String?

    let parameters: Parameters

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyTypeString = try container.decode(String.self, forKey: .keyType)
        guard let keyType = KeyType(rawValue: keyTypeString) else {
            throw CryptoError.JWKFailed(reason: .unsupportedKeyType(keyTypeString))
        }

        self.keyType = keyType
        keyUse = try container.decodeIfPresent(PublicKeyUse.self, forKey: .keyUse)
        keyID = try container.decodeIfPresent(String.self, forKey: .keyID)

        let singleContainer = try decoder.singleValueContainer()
        parameters = try singleContainer.decode(Parameters.self)
    }

    func getKeyData() throws -> Data {
        switch parameters {
        case .rsa(let rsaParams):
            return try rsaParams.getKeyData()
        case .ec(let ecParams):
            return try ecParams.getKeyData()
        }
    }
}

struct JWKSet: Decodable {

    struct Dummy: Decodable {}

    let keys: [JWK]

    enum CodingKeys: String, CodingKey {
        case keys
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = try container.nestedUnkeyedContainer(forKey: .keys)
        var supportedKeys = [JWK]()
        while !nestedContainer.isAtEnd {
            do {
                let key = try nestedContainer.decode(JWK.self)
                supportedKeys.append(key)
            } catch {
                // Failing decoding will not increase container's currentIndex. Let it decode successfully.
                _ = try nestedContainer.decode(Dummy.self)
                Log.print("\(error)")
            }
        }
        keys = supportedKeys
    }

    func getKeyByID(_ keyID: String) -> JWK? {
        return keys.first { $0.keyID == keyID }
    }
}
