//
//  ChatService.swift
//  ChatRoom
//
//  Created by koofrank on 2018/11/16.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SocketRocket
import Repeat

public class ChatService: NSObject {
    static let host = "ws://47.91.242.71:9099/ws"
    lazy var socket = SRWebSocket(url: URL(string: ChatService.host)!)

    static var _shared: ChatService?
    public static var shared: ChatService {
        return guardSharedProperty(_shared)
    }

    public var provider: ChatServiceProvider!
    var timer: Repeater?

    public let chatServiceDidClosed = Delegate<(code: Int, reason: String), Void>()
    public let chatServiceDidFail = Delegate<Error, Void>()
    public let chatServiceDidDisConnected = Delegate<(), Void>()
    public let chatServiceDidConnected = Delegate<(), Void>()
    public let chatServiceDidSended = Delegate<(), Void>()

    public convenience init(_ uuid: String) {
        self.init()

        self.provider = ChatServiceProvider(uuid, channel: "")
        ChatService._shared = self
    }

    private override init() {
        super.init()
        openHeart()
    }

    public func connect(_ chanel: String) {
        self.provider.switchChanel(chanel)

        socket.delegate = self
        socket.open()
    }

    public func disconnect() {
        self.socket.close()
    }

    public func reconnect() {
        if socket.readyState == SRReadyState.CLOSED {
            socket.close()
            socket = SRWebSocket(url: URL(string: ChatService.host)!)
            socket.delegate = self
            socket.open()
        }
    }

    public func send(_ str: String) {
        if checkNetworConnected() {
            try? socket.send(string: str)
            chatServiceDidSended.call()
        }
    }

    func checkNetworConnected() -> Bool {
        if socket.readyState == SRReadyState.OPEN {
            return true
        }

        return false
    }

    func openHeart() {
        self.timer = Repeater.every(.seconds(30), { [weak self] _ in
            guard let self = self else { return }
            if self.checkNetworConnected() {
                try? self.socket.sendPing(nil)
            }
        })
    }

}

extension ChatService: SRWebSocketDelegate {
    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        try? socket.send(string: self.provider.login())
        chatServiceDidConnected.call()
    }

    public func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        chatServiceDidFail.call(error)
    }

    public func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        chatServiceDidClosed.call((code: code, reason: reason ?? ""))
    }

    public func webSocket(_ webSocket: SRWebSocket, didReceivePingWith data: Data?) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceivePong pongData: Data?) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        self.provider.parse(string)
    }
}
