//
//  OCOWebSocketService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/10.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SocketRocket
import SwiftyJSON
import SwiftyUserDefaults
import JSONRPCKit

typealias WebSocketJSONResponse = (JSON) -> Void

/// limit_order_status
/// https://github.com/CybexDex/cybex-node-doc/blob/master/limit-order-status-api/limit_order_status.md
class OCOWebSocketService: NSObject {
    static var host: String {
        return Defaults.isTestEnv ? "wss://shenzhen.51nebula.com" : "wss://apihk.cybex.io"
    }

    private var batchFactory: BatchFactory!

    lazy var socket = SRWebSocket(url: URL(string: OCOWebSocketService.host)!)
    private(set) var idGenerator: JsonIdGenerator = JsonIdGenerator()
    private var responses: [Int: WebSocketJSONResponse] = [:] //id: response callback

    public var messageCanSend = Delegate<(), Void>()

    var limitOrderApiId: UInt64 = 0

    let lock = NSLock()

    var isConnecting = false

    override init() {
        super.init()

        self.batchFactory = BatchFactory(version: "2.0", idGenerator: self.idGenerator)
    }

    public func connect() {
        if !checkNetworConnected()  {
            socket.delegate = self
            socket.open()
        }
    }

    public func disconnect() {
        self.socket.close()

        responses.removeAll()
        self.idGenerator = JsonIdGenerator()
        self.batchFactory.idGenerator = self.idGenerator
    }

    public func reconnect() {
        lock.lock()
        defer {
            lock.unlock()
        }

        if isConnecting {
            return
        }

        isConnecting = true

        if !checkNetworConnected()  {
            socket.close()
            socket = SRWebSocket(url: URL(string: OCOWebSocketService.host)!)
            socket.delegate = self
            socket.open()
        }
    }

    func checkNetworConnected() -> Bool {
        if socket.readyState == SRReadyState.OPEN {
            return true
        }

        return false
    }

    func registerId() {
        if let id = self.idGenerator.next().value as? Int {
            let requestEndpoint: [String: Any] = ["method": "call", "params": [1, "limit_order_status", []], "id": id]
            let writeJSON: JSON = JSON(requestEndpoint)
            let data = try? writeJSON.rawData()

            try? socket.send(data: data)
        }
    }

    func send<Request: JSONRPCKit.Request>(request: Request) {
        if !checkNetworConnected()  {
            return
        }
        if let rpcRequest = request as? JSONRPCResponse {
            let block: WebSocketJSONResponse = { data in
                if !(data["error"].object is NSNull) {
                    rpcRequest.response(data.object)
                } else if let object = try? rpcRequest.transferResponse(from: data["result"].object) {
                    rpcRequest.response(object)
                } else {
                    rpcRequest.response(data)
                }
            }

            var requestEndpoint = self.batchFactory.create(request).requestObject
            if var body = requestEndpoint as? [String: Any], var params = body["params"] as? [Any], let id = body["id"] as? Int {
                params.prepend(self.limitOrderApiId)
                body["params"] = params
                requestEndpoint = body

                responses[id] = block
            }

            let writeJSON: JSON = JSON(requestEndpoint)
            let data = try? writeJSON.rawData()

            try? socket.send(data: data)
        }

    }
}


extension OCOWebSocketService: SRWebSocketDelegate {
    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        isConnecting = false

        registerId()
    }

    public func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        //可能网络已经断开
        isConnecting = false
    }

    public func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        //100 主动断开
        isConnecting = false
    }

    public func webSocket(_ webSocket: SRWebSocket, didReceivePingWith data: Data?) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceivePong pongData: Data?) {

    }

    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        let messages = JSON(parseJSON: string)

        let id = messages["id"].intValue

        if id == 1, let result = messages["result"].int, result != 0 {
            self.limitOrderApiId = UInt64(result)
            messageCanSend.call()
            return
        }

        if let response = responses[id] {
            response(messages)

            responses.removeValue(forKey: id)
        }

    }
}
