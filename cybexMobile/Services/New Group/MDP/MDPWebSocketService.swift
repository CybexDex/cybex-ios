//
//  MDPWebSocketService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/10.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SocketRocket
import SwiftyJSON
import SwiftyUserDefaults

class MDPWebSocketService: NSObject {
    enum SubscribeType: String {
        case orderbook = "ORDERBOOK"
        case ticker = "TICKER"

        var topic: String {
            return self.rawValue
        }
    }

    static var host: String {
       return Defaults.isTestEnv ? "ws://47.244.40.252:18888" : "wss://mdp.cybex.io"
    }

    lazy var socket = SRWebSocket(url: URL(string: MDPWebSocketService.host)!)

    public let mdpServiceDidConnected = Delegate<(), Void>()
    public let tickerDataDidReceived = Delegate<(Decimal, Pair), Void>()
    public let orderbookDataDidReceived = Delegate<(OrderBook, Pair), Void>()

    let lock = NSLock()

    var isConnecting = false
    var baseName: String = ""
    var quoteName: String = ""

    convenience init(_ baseName: String, quoteName: String) {
        self.init()

        self.baseName = baseName
        self.quoteName = quoteName
    }

    private override init() {
        super.init()
    }

    public func connect() {
        if !checkNetworConnected()  {
            socket.delegate = self
            socket.open()
        }
    }

    public func disconnect() {
        self.socket.close()
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
            socket = SRWebSocket(url: URL(string: MDPWebSocketService.host)!)
            socket.delegate = self
            socket.open()
        }
    }

    public func subscribeOrderBook(_ depth: Int, count: Int) {
        if checkNetworConnected() {

            let message = [
                "\(SubscribeType.orderbook.topic)",
                "\(self.quoteName.replacingOccurrences(of: ".", with: "_"))\(self.baseName.replacingOccurrences(of: ".", with: "_"))",
                "\(depth)",
                "\(count)"
            ].joined(separator: ".")

            sendTopic(message)
        }
    }

    public func unSubscribeOrderBook(_ depth: Int, count: Int) {
        if checkNetworConnected() {

            let message = [
                "\(SubscribeType.orderbook.topic)",
                "\(self.quoteName.replacingOccurrences(of: ".", with: "_"))\(self.baseName.replacingOccurrences(of: ".", with: "_"))",
                "\(depth)",
                "\(count)"
                ].joined(separator: ".")

            sendTopic(message, subscribe: false)
        }
    }

    public func subscribeTicker() {
        if checkNetworConnected() {
            let message = [
                "\(SubscribeType.ticker.topic)",
                "\(self.quoteName.replacingOccurrences(of: ".", with: "_"))\(self.baseName.replacingOccurrences(of: ".", with: "_"))"
                ].joined(separator: ".")

            sendTopic(message)
        }
    }

    public func unSubscribeTicker() {
        if checkNetworConnected() {
            let message = [
                "\(SubscribeType.ticker.topic)",
                "\(self.quoteName.replacingOccurrences(of: ".", with: "_"))\(self.baseName.replacingOccurrences(of: ".", with: "_"))"
                ].joined(separator: ".")

            sendTopic(message, subscribe: false)
        }
    }

    public func sendTopic(_ topic: String, subscribe: Bool = true) {
        let wrapMessage = ["type": subscribe ? "subscribe" : "unsubscribe", "topic": topic]

        guard let message = JSON(wrapMessage).rawString() else { return }
        try? socket.send(string: message)
    }

    func checkNetworConnected() -> Bool {
        if socket.readyState == SRReadyState.OPEN {
            return true
        }
        return false
    }

    fileprivate func topicToPair(_ topic: String) -> Pair {
        let pairStr = topic.components(separatedBy: ".")[1]
        let pair = pairStr.filterOnlySystemPrefix.replacingOccurrences(of: "_", with: ".")

        var baseAssets = MarketConfiguration.marketBaseAssets.map({ $0.name })
        if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable {
            baseAssets.append(contentsOf: MarketConfiguration.gameMarketBaseAssets.map({ $0.name }))
        }
        
        for base in baseAssets {
            let baseName = base
            let quoteName = pair.replacingOccurrences(of: base, with: "")

            if let range = pair.range(of: base),
                range.lowerBound != pair.startIndex,
                baseName.assetID != base,
                quoteName.assetID != quoteName {
                return Pair(base: baseName.assetID, quote: quoteName.assetID)
            }

        }

        return Pair(base: "", quote: "")
    }
}

extension MDPWebSocketService: SRWebSocketDelegate {
    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        isConnecting = false

        mdpServiceDidConnected.call()
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
        if let topic = messages["topic"].stringValue.components(separatedBy: ".").first,
            let type = SubscribeType(rawValue: topic) {

            switch type {
            case .ticker:
                let pair = topicToPair(messages["topic"].stringValue)

                if let price = Decimal(string: messages["px"].stringValue) {
                    tickerDataDidReceived.call((price, pair))
                }
            case .orderbook:
                let bidsAmount = messages["bids"].arrayValue.compactMap({ Decimal(string: $0[1].stringValue) })
                let asksAmount = messages["asks"].arrayValue.compactMap({ Decimal(string: $0[1].stringValue) })
                let pair = topicToPair(messages["topic"].stringValue)

                let bidsTotalAmount = bidsAmount.reduce(0, +)
                let asksTotalAmount = asksAmount.reduce(0, +)

                let bids = messages["bids"].arrayValue.map { (json) -> OrderBook.Order in
                    let volume = json[1].stringValue
                    let volumeDecimal = Decimal(string: volume) ?? 0
                    return OrderBook.Order(price: json[0].stringValue,
                                           volume: volume,
                                           volumePercent: volumeDecimal / bidsTotalAmount)
                }
                let asks = messages["asks"].arrayValue.map { (json) -> OrderBook.Order in
                    let volume = json[1].stringValue
                    let volumeDecimal = Decimal(string: volume) ?? 0
                    return OrderBook.Order(price: json[0].stringValue,
                                           volume: volume,
                                           volumePercent: volumeDecimal / asksTotalAmount)
                }
                let orderbook = OrderBook(bids: bids, asks: asks)
                orderbookDataDidReceived.call((orderbook, pair))
                break
            }
        }
    }
}
