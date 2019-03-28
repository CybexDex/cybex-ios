//
//  secp256k1_swiftTests.swift
//  secp256k1_swiftTests
//
//  Created by Alexander Vlasov on 30.05.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
@testable import secp256k1_swift

class secp256k1_swiftTests: XCTestCase {
    
    func testNonDeterministicSignature() {
        var unsuccesfulNondeterministic = 0;
        var allAttempts = 0
        for _ in 0 ..< 10000 {
            guard let randomHash = SECP256K1.randomBytes(length: 32) else {return XCTFail()}
            guard let randomPrivateKey = SECP256K1.randomBytes(length: 32) else {return XCTFail()}
            guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
            allAttempts = allAttempts + 1
            let signature = SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: true)
            guard let serialized = signature.serializedSignature else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
            guard let recovered = SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true) else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
            guard let original = SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true) else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
            guard recovered == original else {
                unsuccesfulNondeterministic = unsuccesfulNondeterministic + 1
                continue
            }
        }
        print("Problems with \(unsuccesfulNondeterministic) non-deterministic signatures out from \(allAttempts)")
        XCTAssert(unsuccesfulNondeterministic == 0)
    }
    
    func testDeterministicSignature() {
        var unsuccesfulDeterministic = 0;
        var allAttempts = 0
        for _ in 0 ..< 10000 {
            let randomHash = SECP256K1.randomBytes(length: 32)!
            let randomPrivateKey = SECP256K1.randomBytes(length: 32)!
            guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
            allAttempts = allAttempts + 1
            let signature = SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: false)
            guard let serialized = signature.serializedSignature else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            guard let recovered = SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true) else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            guard let original = SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true) else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            guard recovered == original else {
                unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                continue
            }
            
        }
        print("Problems with \(unsuccesfulDeterministic) deterministic signatures out from \(allAttempts)")
        XCTAssert(unsuccesfulDeterministic == 0)
    }
    
    func testPrivateToPublic() {
        let randomPrivateKey = SECP256K1.randomBytes(length: 32)!
        guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {return XCTFail()}
        guard var previousPublic = SECP256K1.privateKeyToPublicKey(privateKey: randomPrivateKey) else {return XCTFail()}
        for _ in 0 ..< 100000 {
            guard let pub = SECP256K1.privateKeyToPublicKey(privateKey: randomPrivateKey) else {return XCTFail()}
            guard Data(SECP256K1.toByteArray(previousPublic.data)) == Data(SECP256K1.toByteArray(pub.data)) else {
                return XCTFail()
            }
            previousPublic = pub
        }
    }
    
    func testSerializationAndParsing() {
        for _ in 0 ..< 1024 {
            let randomHash = SECP256K1.randomBytes(length: 32)!
            let randomPrivateKey = SECP256K1.randomBytes(length: 32)!
            guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
            guard var signature = SECP256K1.recoverableSign(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: true) else {return XCTFail()}
            guard let serialized = SECP256K1.serializeSignature(recoverableSignature: &signature) else {return XCTFail()}
            guard let parsed = SECP256K1.parseSignature(signature: serialized) else {return XCTFail()}
            let sigData = Data(SECP256K1.toByteArray(signature.data))
            let parsedData = Data(SECP256K1.toByteArray(parsed.data))
            guard sigData == parsedData else {
                for i in 0 ..< sigData.count {
                    if sigData[i] != parsedData[i] {
                        print(i)
                    }
                }
                return XCTFail()
            }
        }
    }
    
    func testPerformanceExample() {
        print("Testing 1000000 signatures with recovery")
        // This is an example of a performance test case.
        self.measure {
            func testDeterministicSignature() {
                var unsuccesfulDeterministic = 0;
                var allAttempts = 0
                for _ in 0 ..< 1000000 {
                    let randomHash = SECP256K1.randomBytes(length: 32)!
                    let randomPrivateKey = SECP256K1.randomBytes(length: 32)!
                    guard SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey) else {continue}
                    allAttempts = allAttempts + 1
                    let signature = SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: false)
                    guard let serialized = signature.serializedSignature else {
                        unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                        continue
                    }
                    guard let recovered = SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true) else {
                        unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                        continue
                    }
                    guard let original = SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true) else {
                        unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                        continue
                    }
                    guard recovered == original else {
                        unsuccesfulDeterministic = unsuccesfulDeterministic + 1
                        continue
                    }
                }
                XCTAssert(unsuccesfulDeterministic == 0)
            }
        }
    }
    
}
