//
//  NFCManager.swift
//  cybexMobile
//
//  Created by koofrank on 2019/2/22.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import CoreNFC

@available(iOS 11.0, *)
class NFCManager: NSObject {
    static let shared = NFCManager()

    var session: NFCNDEFReaderSession?
    var didReceivedMessage = Delegate<Card, Void>()

    func begin() {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }
}

@available(iOS 11.0, *)
extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // Process detected NFCNDEFMessage objects.
            let card = Utils.parseNDEFMessage(messages)
            self.didReceivedMessage.call(card)
        }
    }

    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    
                }
            }
        }

        // A new session instance is required to read new tags.
        self.session = nil
    }
}
