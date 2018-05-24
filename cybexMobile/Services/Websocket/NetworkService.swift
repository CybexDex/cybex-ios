//
//  NetworkService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Starscream
import JSONRPCKit
import SwiftyJSON
import EZSwiftExtensions
import PromiseKit
import AwaitKit

enum NodeURLString:String {
  case shanghai = "wss://shanghai.51nebula.com"
  case beijing = "wss://beijing.51nebula.com"
  case hongkong = "wss://hongkong.cybex.io"
  case singapore = "wss://singapore-01.cybex.io"
  case tokyo = "wss://tokyo-01.cybex.io"
  case korea = "wss://korea-01.cybex.io"
  
  static var all:[NodeURLString] {
    return [.shanghai, .beijing, .hongkong, .singapore, .tokyo, .korea]
  }
}

class WebsocketService {
  private var autoConnectCount = 0
  private var isConnecting:Bool = false
  private var isFetchingID:Bool = false

  private var requests:[(String, Any, ()->())] = []
  private var requesting:[String: (String, Any, ()->())] = [:]

  private var socket = WebSocket(url: URL(string: NodeURLString.all[0].rawValue)!)
  var callbackQueue = DispatchQueue.main {
    didSet {
      socket.callbackQueue = callbackQueue
    }
  }

  private var testsockets:[WebSocket] = []

  private var batchFactory:BatchFactory!
  private(set) var idGenerator:JsonIdGenerator = JsonIdGenerator()

  private var currentNode:NodeURLString?
  
  var needAutoConnect = true
  var ids:[apiCategory:Int] = [:] {
    didSet {
      if ids.count == 3 {
        self.isFetchingID = false
        
        refreshData()
        handlerRequestPool()
      }
    }
  }

  private init() {
    self.batchFactory = BatchFactory(version: "2.0", idGenerator:self.idGenerator)

//    connect()
  }
  
  static let shared = WebsocketService()
  
  private func detectFastNode() -> Promise<NodeURLString> {
    let (promise, seal) = Promise<NodeURLString>.pending()

    for (idx, node) in NodeURLString.all.enumerated() {
      var testsocket:WebSocket!
      
      if idx < testsockets.count {
        testsocket = testsockets[idx]
      }
      else {
        testsocket = WebSocket(url: URL(string:node.rawValue)!)
        testsocket.callbackQueue = Await.Queue.await
        testsockets.append(testsocket)
      }
      
      //websocketDidConnect
      testsocket.onConnect = {
        seal.fulfill(node)

        self.testsockets.forEach({ (s) in
          s.disconnect()
        })
      }
      
      /*
       error NSError  domain: "NSPOSIXErrorDomain" - code: 50 网络断开
       error WSError writeTimeoutError 超时 网络延迟
       error nil socket断开
       */
      testsocket.onDisconnect = { error in
        guard let error = error else { return }
        
        seal.reject(error)
      }
    
      
      testsocket.connect()
    }
    
    return promise
  }
  
  func connect() {
    currentNode = nil
    isConnecting = true

    async {
      do {
        let node = try await(self.detectFastNode())
        self.currentNode = node
        self.changeNode(node: node)
      }
      catch {
        ez.runThisAfterDelay(seconds: 10, after: {
          if !self.checkNetworConnected(), self.autoConnectCount <= 5 {
            self.autoConnect()
          }
        })
      }
    }
  }
  
  private func changeNode(node: NodeURLString) {
    print("current node is \(node.rawValue)")
    currentNode = node
    let request = URLRequest(url: URL(string:node.rawValue)!)

    socket.request = request
    socket.delegate = self
    socket.connect()
  }
  
  func checkNetworConnected() -> Bool {
    if !socket.isConnected {
      return false
    }
    
    return true
  }
  
  func reConnect() {
    needAutoConnect = true
    autoConnectCount = 0
    connect()
  }
  
  func disConnect() {
    needAutoConnect = false
    socket.disconnect()
  }
  
  private func autoConnect() {
    guard needAutoConnect else { return }
    autoConnectCount += 1
    
    connect()
  }

  private func preFetchID() {
    ids = [:]
    isFetchingID = false
  }
  
  private func existAllIDs() -> Bool {
    return self.ids.count == 3
  }
  
  private func removeIDs() {
    self.ids.removeAll()
  }
  
}

extension WebsocketService {
  private func fetchIDs() {
    guard !isFetchingID else {
      return
    }
    
    self.isFetchingID = true
    
    let login_re = LoginRequest(username: "", password: "") { _ in
    }
    
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
    
    constructSendRequest(request: login_re)()
    
    for request in registerID_re {
      constructSendRequest(request: request)()
    }
  }
  
  private func preSendAndDetect() -> Bool {
    if !checkNetworConnected() {
      guard !isConnecting else {
        return false
      }
      
      reConnect()
    }
    else {
      guard !existAllIDs() else  {
        return true
      }
      
      guard !isFetchingID else  {
        return false
      }
      
      preFetchID()
      fetchIDs()
    }
    
    return false
  }
  
  private func saveRequest<Request: JSONRPCKit.Request>(request: Request) {
    var exist = false
    
    for re in requests {
      if re.0 == request.digist {
        exist = true
        break
      }
    }
    
    if !exist {
      requests.append((request.digist, request, constructSendRequest(request: request)))
    }
  }
  
  private func constructSendRequest<Request: JSONRPCKit.Request>(request: Request) -> (()->()) {
    return {[weak self] in
      guard let `self` = self else { return }
      
      let batch = self.batchFactory.create(request)
      
      var writeJSON:JSON
      if let revision_request = request as? RevisionRequest {
        writeJSON = JSON(revision_request.revisionParameters(batch.requestObject))
      }
      else {
        writeJSON = JSON(batch.requestObject)
      }
      
      self.socket.write(data: try! writeJSON.rawData())
      
      let id = writeJSON["id"].stringValue
      self.requesting[id] = (request.digist, request, self.constructSendRequest(request: request))
      
      if let index = self.requests.index(where: { (value) -> Bool in
        let (digist, _, _) = value
        
        return digist == request.digist
      }) {
        self.requests.remove(at: index)
      }

    }
  }
  
  private func restoreToRequestList() {
    let filterRegister = requesting.filter { (value) -> Bool in
      let (_, requestObject) = value
      return requestObject.0 != ""
    }
    
    requests += Array(filterRegister.values)
    requesting.removeAll()
  }
  
  private func handlerRequestPool() {
    let requestQueue = requests
    
    for request in requestQueue {
      let retry = request.2
      
      retry()
    }
  }
  
  func send<Request: JSONRPCKit.Request>(request: Request) {
    saveRequest(request: request)
    if preSendAndDetect() {
      handlerRequestPool()
    }
  }
  
  private func refreshData() {
    UIApplication.shared.coordinator().getLatestData()
  }
}


extension WebsocketService: WebSocketDelegate {
  func websocketDidConnect(socket: WebSocketClient) {
    print("websocket is connected")
    isConnecting = false
    
    preFetchID()
    fetchIDs()
  }
  
  func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    isConnecting = false
    
    removeIDs()
    idGenerator = JsonIdGenerator()
    batchFactory.idGenerator = idGenerator
    restoreToRequestList()
    
    if needAutoConnect {
      reConnect()
    }
    
    if let e = error as? WSError {
      print("websocket is disconnected: \(e.message)")
    } else if let e = error {
      print("websocket is disconnected: \(e.localizedDescription)")
    } else {
      print("websocket disconnected")
    }
    
    
  }
  
  func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
    let data = JSON(parseJSON:text)
    
//    if let error = data["error"].dictionary {
//      print(error)
//      return
//    }
    
    guard let id = data["id"].int else {
      if let method = data["method"].string, method == "notice", let params = data["params"].array, let mID = params[0].int {
        if let ids = app_data.subscribeIds, ids.values.contains(mID) {
          let index = ids.values.index(of: mID)!
          let pair = ids.keys[index]
          
          UIApplication.shared.coordinator().request24hMarkets([pair], sub: false)
        }
      }
      return
    }
    
    if let requestData = requesting[id.toString], let request = requestData.1 as? JSONRPCResponse {
      if requestData.1 is SubscribeMarketRequest {
        request.response(id)
        requesting.removeValue(forKey: id.toString)
        return
      }
      
      if let object = try? request.transferResponse(from: data["result"].object) {
        request.response(object)
        requesting.removeValue(forKey: id.toString)
      }
      else {
        request.response(data.object)
        requesting.removeValue(forKey: id.toString)
      }
    }
    
  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
  }
  
}
