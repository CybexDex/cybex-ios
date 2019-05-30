//
//  CybexWebSocketService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/7/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SocketRocket
import JSONRPCKit
import SwifterSwift
import SwiftyJSON
import SwiftyUserDefaults
import RxCocoa

enum NodeURLString: String {
    case shanghai = "wss://shanghai.51nebula.com"
    case beijing = "wss://beijing.51nebula.com"

    case hongkong = "wss://hongkong.cybex.io"
    case singapore = "wss://singapore-01.cybex.io"
    case tokyo = "wss://tokyo-01.cybex.io"
    case korea = "wss://korea-01.cybex.io"
    case hkback = "wss://hkbak.cybex.io"

    case test = "wss://hangzhou.51nebula.com/"
    case test2 = "wss://shenzhen.51nebula.com/"


    case tmp = "ws://10.18.120.241:28090" //local
    case uat = "ws://47.100.98.113:38090" //uat
}

typealias CybexWebSocketResponse = (JSON) -> Void

open class AsyncRequestOperation: AsyncBlockOperation {
    var response: CybexWebSocketResponse!

    init(_ response:@escaping CybexWebSocketResponse, closure: @escaping Closure) {
        super.init(closure: closure)
        self.response = response
    }

}

class CybexWebSocketService: NSObject {
    enum Config: NetworkWebsocketNodeEnv {
        static var productURL: [URL] {
            return [NodeURLString.hongkong, NodeURLString.hkback, NodeURLString.singapore, NodeURLString.tokyo, NodeURLString.korea].map { URL(string: $0.rawValue)! }
        }

        static var devURL: [URL] {
            return [NodeURLString.test, NodeURLString.test2].map { URL(string: $0.rawValue)! }
        }

        static var uatURL: [URL] {
            return [NodeURLString.uat].map { URL(string: $0.rawValue)! }
        }
    }

    private var batchFactory: BatchFactory!
    private(set) var idGenerator: JsonIdGenerator = JsonIdGenerator()

    private var socket = SRWebSocket(url: URL(string: NodeURLString.hongkong.rawValue)!)
    private var testsockets: [SRWebSocket] = []

    private var currentNode: URL?
    private var nodes: [URL] = []

    lazy var disconnectDispatch = debounce(delay: .seconds(AppConfiguration.debounceDisconnectTime), action: {
        if !AppHelper.shared.infront {
            self.disconnect()
        }
    })
    
    var needAutoConnect = true
    private var autoConnectCount = 0
    private let maxAutoConnectCount = 5
    private var errorCount = 0
    private var isConnecting: Bool = false
    private var isDetecting: Bool = false

    private var isClosing = false

    private var queue: OperationQueue!

    var ids: [ApiCategory: Int] = [:]

    static let shared = CybexWebSocketService()

    public let canSendMessage = Delegate<(), Void>()
    let canSendMessageReactive: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private override init() {
        super.init()

        monitor()
        self.queue = OperationQueue()

        self.queue.maxConcurrentOperationCount = 3
        self.queue.isSuspended = true

        self.batchFactory = BatchFactory(version: "2.0", idGenerator: self.idGenerator)
    }

    // MARK: - TestSocket -

    private func isDetectingSocket(_ websocket: SRWebSocket) -> Bool {
        if let isTest = websocket.store["test"] as? Bool {
            return isTest
        }

        return false
    }

    private func closeAllTestSocket() {
        testsockets.forEach { (testsocket) in
            testsocket.close()
        }

        testsockets.removeAll()
    }

    private func detectFastNode() {
        isDetecting = true
        self.currentNode = nil
        Log.print("detecting node .......")

        self.testsockets.removeAll()

        for (idx, node) in nodes.enumerated() {
            var testsocket: SRWebSocket!

            if idx < testsockets.count {
                testsocket = testsockets[idx]
            } else {
                var request = URLRequest(url: node)
                request.timeoutInterval = autoConnectCount.double * 1.0 + 0.5//随着重试次数增加 增加超时时间
                testsocket = SRWebSocket(urlRequest: request)
                testsocket.delegate = self
                testsocket.store = ["test": true]
                testsocket.delegateDispatchQueue = DispatchQueue.main
                testsockets.append(testsocket)
            }

            testsocket.open()
        }

    }

    // MARK: - Public Methods -

    func overload() -> Bool {
        return self.queue.operations.count > 150
    }

    func connect() {
        if !self.isConnecting {
            isConnecting = true
            isClosing = false
            needAutoConnect = true

            nodes = Config.currentEnv
            detectFastNode()
        }
    }

    func disconnect() {
        Log.print("websocket now disconnect by u")

        self.isClosing = true

        self.needAutoConnect = false
        self.socket.close()

        self.isDetecting = false
        self.isConnecting = false
        self.errorCount = 0
        self.autoConnectCount = 0
        self.ids.removeAll()

        closeAllTestSocket()
        self.idGenerator = JsonIdGenerator()
        self.batchFactory.idGenerator = self.idGenerator
        self.queue.cancelAllOperations()
        self.queue.operations.forEach { (operation) in
            if let operation = operation as? AsyncRequestOperation {
                if operation.state == .executing {
                    operation.state = .finished
                }
            }
        }
        self.queue.isSuspended = true
        canSendMessageReactive.accept(false)
    }

    func send<Request: JSONRPCKit.Request>(request: Request, priority: Operation.QueuePriority = .normal) {
        if let rpcRequest = request as? JSONRPCResponse {
            let block: CybexWebSocketResponse = { data in
                if !(data["error"].object is NSNull) {
                    rpcRequest.response(data.object)
                } else if let object = try? rpcRequest.transferResponse(from: data["result"].object) {
                    rpcRequest.response(object)
                } else {
                    rpcRequest.response(data)
                }
            }

            appendRequestToQueue(request, priority: priority, response: block)

            if !self.isConnecting && !self.isClosing && socket.readyState != .OPEN {
                connect()
            }
        }

    }

    func checkNetworConnected() -> Bool {
        if socket.readyState == SRReadyState.OPEN {
            return true
        }

        return false
    }

    private func register() {
        self.ids.removeAll()
        let registerIDRe = [RegisterIDRequest(api: .database) { reId in
            if let reId = reId as? Int {
                var nIds = self.ids
                nIds[.database] = reId
                self.ids = nIds
            }

            }, RegisterIDRequest(api: .networkBroadcast) { reId in
                if let reId = reId as? Int {
                    var nIds = self.ids
                    nIds[.networkBroadcast] = reId
                    self.ids = nIds
                }

            }, RegisterIDRequest(api: .history) { reId in
                if let reId = reId as? Int {
                    var nIds = self.ids
                    nIds[.history] = reId
                    self.ids = nIds
                }

            }]

        for request in registerIDRe {
            send(request: request, priority: .veryHigh)
        }
    }

    private func constructSendData<Request: JSONRPCKit.Request>(request: Request) -> (JSON, String) {
        let batch = self.batchFactory.create(request)

        var writeJSON: JSON

        if let revisionRequest = request as? RevisionRequest {
            writeJSON = JSON(revisionRequest.revisionParameters(batch.requestObject))
        } else {
            writeJSON = JSON(batch.requestObject)
        }

        let sendId = writeJSON["id"].stringValue

        return (writeJSON, sendId)
    }

    private func appendRequestToQueue<Request: JSONRPCKit.Request>(_ request: Request,
                                                                   priority: Operation.QueuePriority = .normal,
                                                                   response:@escaping CybexWebSocketResponse) {
        let sendData = self.constructSendData(request: request)
        let sendId = sendData.1

        let operation = AsyncRequestOperation(response) {[weak self] operation in
            guard let self = self else { return }

            operation.state = .executing

            if self.checkNetworConnected() {
                var json = sendData.0
                if var oldParams = request.parameters as? [Any] {
                    if let api = oldParams[0] as? ApiCategory, let rid = self.ids[api] {
                        oldParams[0] = rid
                    } else {
                        oldParams[0] = 1
                    }
                    json["params"] = JSON(oldParams)

//                    log.info("request: \(json.rawString()!)")

                    let data = try? json.rawData()
                    try? self.socket.send(data: data)
                }
            }
        }

        operation.queuePriority = priority
        if priority == .veryHigh || priority == .high {
            operation.qualityOfService = .userInteractive
        } else {
            operation.qualityOfService = .default
        }

        if let idInt = sendId.int, idInt > 3, self.ids.count < 3 {
            registerOperations().forEach { (opera) in
                operation.addDependency(opera)
            }
        }
        operation.name = sendId

        self.queue.addOperation(operation)
    }

    private func registerOperations() -> [Operation] {
        return self.queue.operations.filter({ $0.name!.int! < 4})
    }

    // MARK: - Nodes -

    private func connectNode(node: URL) {
        if socket.readyState != .OPEN {
            Log.print("connecting node: \(node.absoluteString)")
            UIHelper.showStatusBar(R.string.localizable.socket_loading.key, style: .info)

            self.idGenerator = JsonIdGenerator()
            self.batchFactory.idGenerator = self.idGenerator

            let request = URLRequest(url: node)

            socket = SRWebSocket(urlRequest: request)

            socket.delegate = self
            socket.delegateDispatchQueue = DispatchQueue.main
            socket.open()
        }
    }
}

extension CybexWebSocketService: SRWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
        if isDetectingSocket(webSocket) {
            let request = LoginRequest(username: "", password: "") { (_) in
            }

            let batch = self.batchFactory.create(request)
            let writeJSON: JSON = JSON(batch.requestObject)

            let data = try? writeJSON.rawData()
            try? webSocket.send(data: data)
        } else {
            Log.print(" node: \(webSocket.url!.absoluteString) --- connected")
            UIHelper.showStatusBar(R.string.localizable.socket_success.key, style: .success)

            isConnecting = false
            self.register()

            self.queue.isSuspended = false

            canSendMessageReactive.accept(true)
            canSendMessage.call()
        }

    }

    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {

        if isDetectingSocket(webSocket) {
            errorCount += 1

            if errorCount == nodes.count {
                closeAllTestSocket()

                if needAutoConnect {
                    if autoConnectCount <= maxAutoConnectCount {
                        autoConnectCount += 1
                        errorCount = 0

                        detectFastNode()
                    }
                }

            }
        } else {
            Log.print(error)
            UIHelper.showStatusBar(R.string.localizable.socket_failed.key, style: .danger)

            disconnect()
        }

    }

    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        if self.currentNode == nil && isDetectingSocket(webSocket) {
            self.closeAllTestSocket()

            self.currentNode = URL(string: webSocket.url!.absoluteString)!
            connectNode(node: self.currentNode!)

            return
        } else if self.currentNode == nil {
            return
        }

        guard let message = message as? String else { return }

        //    log.info("enter receieveMessage --- current operations Count: \(queue.operationCount)")
        let data = JSON(parseJSON: message)
//            Log.print("receive message: \(data.rawString()!)\n")

        
        guard let sendId = data["id"].int else {
            return
        }

        self.queue.operations.filter({ $0.name == sendId.description }).forEach { (operation) in
            if let operation = operation as? AsyncRequestOperation, operation.state == .executing {
                operation.response(data)
                operation.state = .finished
            }
        }
        //    log.info("end receieveMessage --- current operations Count: \(queue.operationCount)")
    }
}
