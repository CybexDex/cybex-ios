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
    var needReadRepeat = true
    var didReceivedMessage = Delegate<Card, Void>()
    var pinCodeErrorMessage = Delegate<Card, Void>()

    var pinCode: String = "" {
        didSet {
            Defaults[.pinCode] = pinCode
        }
    }

    private override init() {
        super.init()
        initSession()
    }

    func initSession() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
    }

    func needPinCode() -> Bool {
        return pinCode.isEmpty
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
        guard let card = Utils.parseNDEFMessage(messages: messages) else {
            self.session?.invalidate()
            return
        }

        var privateKey: String = card.oneTimePrivateKey
        var signature: String = card.oneTimeSignature

        let status = card.transactionPinStatus
        if status {
            let data = card.validatorPin(self.pinCode)
            if data.success {
                privateKey = data.privateKey
                signature = data.signature
            }
            else {
                pinCodeErrorMessage.call(card)
                self.session?.invalidate()
                return
            }
        }
        
        Log.print("------reading tag..........")
        guard let sign = card.getBlockchainSignature(signature), let signHex = unhexlify(sign), Card.isCanonical(signHex) else {
            needReadRepeat = true
            Log.print("------tag not match")

            repeatRead()
            return
        }

        Log.print("------", sign)

        needReadRepeat = false
//        let onePkKey = Card.compressedPublicKey(card.oneTimePublicKey)
//        let pkKey = Card.compressedPublicKey(card.blockchainPublicKey)
//        let pvKey = Card.compressedPrivateKey(privateKey)
        self.didReceivedMessage.call(card)
        self.session?.invalidate()
    }

    func repeatRead() {
        if needReadRepeat {
            needReadRepeat = false
            self.session?.invalidate()

            SwifterSwift.delay(milliseconds: 100) {
                self.begin()
            }
        }
    }

    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if readerError.code == .readerSessionInvalidationErrorFirstNDEFTagRead, needReadRepeat {

            }

        }

        Log.print("-------", error)
        // A new session instance is required to read new tags.
        initSession()
    }
}
