//
//  NFCManager.swift
//  cybexMobile
//
//  Created by koofrank on 2019/2/22.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import CoreNFC
import secp256k1
import CryptoSwift
import SwifterSwift
import SwiftyUserDefaults

@available(iOS 11.0, *)
class NFCManager: NSObject {
    static let shared = NFCManager()

    var session: NFCNDEFReaderSession?
    var didReceivedMessage = Delegate<Card, Void>()
    var pinCodeErrorMessage = Delegate<Card, Void>()
    var pinCodeNotExist = Delegate<Card, Void>()
    var cardNotMatched = Delegate<Card, Void>()

    private override init() {
        super.init()
        initSession()
    }

    func initSession() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
    }

    func start() {
        session?.invalidate()
        initSession()
        begin()
    }

    private func begin() {
        if NFCNDEFReaderSession.readingAvailable {
            Log.print("------begin reading")

            self.session?.begin()
        }
    }
}

@available(iOS 11.0, *)
extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Process detected NFCNDEFMessage objects.
        guard var card = Utils.parseNDEFMessage(messages: messages) else {
            self.session?.invalidate()
            return
        }

        var privateKey: String = card.oneTimePrivateKey
        var signature: String = card.oneTimeSignature

        let pkKey = Card.compressedPublicKey(card.blockchainPublicKey)
        if let cachedPubkey = UserManager.shared.getCachedEnotesKeysExcludePrivate()?.activeKey?.publicKey, cachedPubkey != pkKey {
            DispatchQueue.main.async {
                appCoodinator.topViewController()?.showToastBox(false, message: R.string.localizable.enotes_not_match.key.localized())

                self.cardNotMatched.call(card)
            }
            self.session?.invalidate()
            return
        }

        let onePkKey = Card.compressedPublicKey(card.oneTimePublicKey)
        let pvKey = Card.compressedPrivateKey(privateKey)

        card.marshalCard("", onePubkey: onePkKey, onePriKey: pvKey, pubkey: pkKey)

        let status = card.transactionPinStatus
        if status {
            if let pincode = Defaults[.pinCodes][pkKey] as? String {
                let data = card.validatorPin(pincode)
                if data.success {
                    privateKey = data.privateKey
                    signature = data.signature
                } else {
                    DispatchQueue.main.async {
                        self.pinCodeErrorMessage.call(card)
                    }
                    self.session?.invalidate()
                    return
                }
            } else {
                DispatchQueue.main.async {
                    self.pinCodeNotExist.call(card)
                }
                self.session?.invalidate()
                return
            }
        }
        
        Log.print("------reading tag..........")
        guard let sign = card.getBlockchainSignature(signature) else {
            self.session?.invalidate()
            return
        }
        card.marshalCard(sign, onePubkey: onePkKey, onePriKey: pvKey, pubkey: pkKey)

        Log.print("------", sign)

        DispatchQueue.main.async {
            self.didReceivedMessage.call(card)
        }
        self.session?.invalidate()
    }


    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if readerError.code == .readerSessionInvalidationErrorFirstNDEFTagRead {

            }

        }

        Log.print("-------", error)
        // A new session instance is required to read new tags.
        initSession()
    }
}
