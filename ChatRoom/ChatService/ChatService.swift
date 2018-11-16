//
//  ChatService.swift
//  ChatRoom
//
//  Created by koofrank on 2018/11/16.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SocketRocket

public class ChatService: NSObject {
    static let host = "ws://47.91.242.71:9099/ws"
    lazy var socket = SRWebSocket(url: URL(string: ChatService.host)!)

    public override init() {

    }

    public func connect() {

        socket.delegate = self
        socket.open()
    }

    public func send(_ str: String) {
        try? socket.send(string: """
{ "Type": 2, "Data": { "UserName": "daizong798", "Message": "nihao", "Sign":"209dae8ac1e36372223fc5092bb6c494b097b10e5365ed37dd4710a240727c1f933c3b48cc77ca65df123697b8095895f17ec6b91fd605bb60fc1d55043b49d86b" } }
""")
    }
}

extension ChatService: SRWebSocketDelegate {
    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        try? socket.send(string: """
{
    "Type":    1,
    "Data":    {
        "Channel": "BTC/ETH",
        "MessageSize": "300",
        "DeviceID": "abc-edf-lgh"
    }
}
""")

        let result = try? socket.sendPing(nil)
        print(result)
        
    }

    public func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceivePingWith data: Data?) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceivePong pongData: Data?) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {

    }



}
