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
import AsyncOperation
import SwiftyUserDefaults

enum NodeURLString:String {
    case shanghai = "wss://shanghai.51nebula.com"
    case beijing = "wss://beijing.51nebula.com"
    case hongkong = "wss://hongkong.cybex.io"
    case singapore = "wss://singapore-01.cybex.io"
    case tokyo = "wss://tokyo-01.cybex.io"
    case korea = "wss://korea-01.cybex.io"
    
    case test = "wss://hangzhou.51nebula.com/"
    static var all:[NodeURLString] {
        //    return [.test]
        return [.shanghai, .beijing, .hongkong, .singapore, .tokyo, .korea]
    }
}

typealias CybexWebSocketResponse = (JSON) -> ()

open class AsyncRequestOperation: AsyncBlockOperation {
    var response:CybexWebSocketResponse!
    
    init(_ response:@escaping CybexWebSocketResponse, closure: @escaping Closure) {
        super.init(closure: closure)
        self.response = response
    }
    
}

class CybexWebSocketService: NSObject {
    private var batchFactory:BatchFactory!
    private(set) var idGenerator:JsonIdGenerator = JsonIdGenerator()
    
    private var socket = SRWebSocket(url: URL(string: NodeURLString.all[0].rawValue)!)
    private var testsockets:[SRWebSocket] = []
    
    private var currentNode:NodeURLString?
    
    var needAutoConnect = true
    private var autoConnectCount = 0
    private let maxAutoConnectCount = 5
    private var errorCount = 0
    private var isConnecting:Bool = false
    private var isDetecting:Bool = false
    
    private var isClosing = false
    
    private var queue:OperationQueue!
    
    var ids:[apiCategory:Int] = [:]
    
    static let shared = CybexWebSocketService()
    
    private override init() {
        super.init()
        self.queue = OperationQueue()
        
        self.queue.maxConcurrentOperationCount = 3
        self.queue.isSuspended = true
        
        self.batchFactory = BatchFactory(version: "2.0", idGenerator:self.idGenerator)
    }
    
    //MARK: - TestSocket -
    
    private func isDetectingSocket(_ websocket:SRWebSocket) -> Bool {
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
        log.debug("detecting node .......")
        
        
        self.testsockets.removeAll()
        
        for (idx, node) in NodeURLString.all.enumerated() {
            var testsocket:SRWebSocket!
            
            if idx < testsockets.count {
                testsocket = testsockets[idx]
            }
            else {
                var request = URLRequest(url: URL(string:node.rawValue)!)
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
    
    //MARK: - Public Methods -
    
    func overload() -> Bool {
        return self.queue.operations.count > 150
    }
    
    func connect() {
        if !self.isConnecting {
            isConnecting = true
            isClosing = false
            needAutoConnect = true
            if Defaults.hasKey(.environment) && Defaults[.environment] == "test" {
                log.debug("test detecting node .....https://hangzhou.51nebula.com/")
                connectNode(node: NodeURLString.test)
                return
            }
            detectFastNode()
        }
    }
    
    func disconnect() {
        log.warning("websocket now disconnect by u")
        
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
        self.queue.operations.forEach { (op) in
            if let operation = op as? AsyncRequestOperation {
                if operation.state == .executing {
                    operation.state = .finished
                }
            }
        }
        self.queue.isSuspended = true
    }
    
    func send<Request: JSONRPCKit.Request>(request: Request, priority: Operation.QueuePriority = .normal) {
        if let rpcRequest = request as? JSONRPCResponse {
            let block:CybexWebSocketResponse = { data in
                if !(data["error"].object is NSNull) {
                    rpcRequest.response(data.object)
                }
                else if let object = try? rpcRequest.transferResponse(from: data["result"].object) {
                    rpcRequest.response(object)
                }
                else {
                    rpcRequest.response(data)
                }
            }
            
            appendRequestToQueue(request, priority:priority, response: block)
            
            
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
        let registerID_re = [RegisterIDRequest(api: .database) { re_id in
            if let re_id = re_id as? Int {
                var n_ids = self.ids
                n_ids[.database] = re_id
                self.ids = n_ids
            }
            
            }, RegisterIDRequest(api: .network_broadcast) { re_id in
                if let re_id = re_id as? Int {
                    var n_ids = self.ids
                    n_ids[.network_broadcast] = re_id
                    self.ids = n_ids
                }
                
            }, RegisterIDRequest(api: .history) { re_id in
                if let re_id = re_id as? Int {
                    var n_ids = self.ids
                    n_ids[.history] = re_id
                    self.ids = n_ids
                }
                
            }]
        
        for request in registerID_re {
            send(request: request, priority:.veryHigh)
        }
    }
    
    private func constructSendData<Request: JSONRPCKit.Request>(request: Request) -> (JSON, String) {
        let batch = self.batchFactory.create(request)
        
        var writeJSON:JSON
        
        if let revision_request = request as? RevisionRequest {
            writeJSON = JSON(revision_request.revisionParameters(batch.requestObject))
        }
        else {
            writeJSON = JSON(batch.requestObject)
        }
        
        let id = writeJSON["id"].stringValue
        
        return (writeJSON, id)
    }
    
    private func appendRequestToQueue<Request: JSONRPCKit.Request>(_ request: Request, priority: Operation.QueuePriority = .normal, response:@escaping CybexWebSocketResponse) {
        let sendData = self.constructSendData(request: request)
        let id = sendData.1
        
        let operation = AsyncRequestOperation(response) {[weak self] operation in
            guard let `self` = self else { return }
            
            operation.state = .executing
            
            if self.checkNetworConnected() {
                var json = sendData.0
                if var oldParams = request.parameters as? [Any] {
                    if let api = oldParams[0] as? apiCategory, let rid = self.ids[api] {
                        oldParams[0] = rid
                    }
                    else {
                        oldParams[0] = 1
                    }
                    json["params"] = JSON(oldParams)
                    
                    //          log.info("request: \(json.rawString()!)")
                    
                    let data = try? json.rawData()
                    try? self.socket.send(data: data)
                }
            }
        }
        
        operation.queuePriority = priority
        if priority == .veryHigh || priority == .high {
            operation.qualityOfService = .userInteractive
        }
        else {
            operation.qualityOfService = .default
        }
        
        if let idInt = id.int, idInt > 3, self.ids.count < 3 {
            registerOperations().forEach { (op) in
                operation.addDependency(op)
            }
        }
        operation.name = id
        
        self.queue.addOperation(operation)
    }
    
    private func registerOperations() -> [Operation] {
        return self.queue.operations.filter({ $0.name!.int! < 4})
    }
    
    //MARK: - Nodes -
    
    private func connectNode(node: NodeURLString) {
        if socket.readyState != .OPEN {
            log.info("connecting node: \(node.rawValue)")
            
            self.idGenerator = JsonIdGenerator()
            self.batchFactory.idGenerator = self.idGenerator
            
            let request = URLRequest(url: URL(string:node.rawValue)!)
            
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
            let writeJSON:JSON = JSON(batch.requestObject)
            
            let data = try? writeJSON.rawData()
            try? webSocket.send(data: data)
        }
            
        else {
            log.info(" node: \(webSocket.url!.absoluteString) --- connected")
            
            isConnecting = false
            self.register()
            
            self.queue.isSuspended = false
            
            app_coodinator.getLatestData()
        }
        
    }
    
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        
        if isDetectingSocket(webSocket) {
            errorCount += 1
            
            if errorCount == NodeURLString.all.count {
                closeAllTestSocket()
                
                if needAutoConnect {
                    if autoConnectCount <= maxAutoConnectCount {
                        autoConnectCount += 1
                        errorCount = 0
                        
                        detectFastNode()
                    }
                }
                
            }
        }
        else {
            log.error(error)
            
            disconnect()
        }
        
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        if self.currentNode == nil && isDetectingSocket(webSocket) {
            self.closeAllTestSocket()
            
            self.currentNode = NodeURLString(rawValue: webSocket.url!.absoluteString)!
            connectNode(node: self.currentNode!)
            
            return
        }
        else if self.currentNode == nil {
            return
        }
        
        guard let message = message as? String else { return }
        
        //    log.info("enter receieveMessage --- current operations Count: \(queue.operationCount)")
        let data = JSON(parseJSON:message)
        //    log.info("receive message: \(data.rawString()!)")
        
        guard let id = data["id"].int else {
            return
        }
        
        self.queue.operations.filter({ $0.name == id.description }).forEach { (op) in
            if let operation = op as? AsyncRequestOperation, operation.state == .executing {
                operation.response(data)
                operation.state = .finished
            }
        }
        //    log.info("end receieveMessage --- current operations Count: \(queue.operationCount)")
    }
}
