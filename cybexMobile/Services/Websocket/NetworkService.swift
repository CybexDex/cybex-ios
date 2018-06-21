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
import SwifterSwift
import PromiseKit
import AwaitKit
import Device

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

typealias RequestingType = [String: RequestsType]
typealias RequestsType = (String, Any, ()->())

class WebsocketService {
  private var last_send_time:TimeInterval = 0
  private let semaphore = DispatchSemaphore(value: 1)
  private let requests_queue_concurrent = DispatchQueue(label: "com.nbltrsut.requests_queue_concurrent", attributes: .concurrent)
  private let requesting_queue_concurrent = DispatchQueue(label: "com.nbltrsut.requesting_queue_concurrent", attributes: .concurrent)

  private var autoConnectCount = 0
  private var isConnecting:Bool = false
  private var isFetchingID:Bool = false

  private var requests:[RequestsType] = []
  private var requesting:RequestingType = [:]

  private var socket = WebSocket(url: URL(string: NodeURLString.all[0].rawValue)!)

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

    var errorCount = 0
    for (idx, node) in NodeURLString.all.enumerated() {
      var testsocket:WebSocket!
      
      if idx < testsockets.count {
        testsocket = testsockets[idx]
      }
      else {
        var request = URLRequest(url: URL(string:node.rawValue)!)
        request.timeoutInterval = autoConnectCount.double * 1.0 + 0.1//随着重试次数增加 增加超时时间
        testsocket = WebSocket(request: request)
    
        testsocket.callbackQueue = Await.Queue.await
        testsockets.append(testsocket)
      }
      
      //websocketDidConnect
      testsocket.onConnect = {
        seal.fulfill(node)

      }
      
      /*
       error NSError  domain: "NSPOSIXErrorDomain" - code: 50 网络断开
       error WSError writeTimeoutError 超时 网络延迟
       error nil socket断开
       */
      testsocket.onDisconnect = { error in
        guard let error = error else { return }
        log.error(error)
        
        errorCount += 1
        
        if errorCount == NodeURLString.all.count {
          seal.reject(error)
        }
      }
    
      
      testsocket.connect()
    }
    
    return promise
  }
  
  private func pingTest() {
    var errorCount = 0
    
    for (_, node) in NodeURLString.all.enumerated() {
      let helper = PingHelper()
      helper.host = node.rawValue.components(separatedBy: "//")[1]
      helper.ping { (complete) in
        if complete {
          
        }
        else {
          errorCount += 1
          if errorCount == NodeURLString.all.count {
            
          }
        }
      }
      
    }
  }
  
  func connect() {
    currentNode = nil
    isConnecting = true

    async {
      do {
        let node = try await(self.detectFastNode())
        main {
          self.currentNode = node
          self.changeNode(node: node)
        }

      }
      catch {
        main {
          SwifterSwift.delay(milliseconds: 10000, completion: {
            if !self.checkNetworConnected(), self.autoConnectCount <= 5 {
              self.autoConnect()
            }
          })
        }
      }
    }
  }
  
  private func changeNode(node: NodeURLString) {
    print("current node is \(node.rawValue)")
    currentNode = node
    let request = URLRequest(url: URL(string:node.rawValue)!)
    
    socket.request = request
    socket.delegate = self
    socket.callbackQueue = DispatchQueue.global()
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
    requests = []
    
    self.requesting_queue_concurrent.async(flags: .barrier) {[weak self] in
      guard let `self` = self else { return }
      self.requesting = [:]
    }
    
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
      self.requesting_queue_concurrent.async(flags: .barrier) {[weak self] in
        guard let `self` = self else { return }
        self.requesting[id] = (request.digist, request, self.constructSendRequest(request: request))
      }
      
      if let index = self.requests.index(where: { (value) -> Bool in
        let (digist, _, _) = value
        
        return digist == request.digist
      }) {
        self.requests.remove(at: index)
      }

    }
  }
  
  private func restoreToRequestList() {
    var filterRegisters:[RequestsType]!
    
    requesting_queue_concurrent.sync { [weak self] in
      guard let `self` = self else { return }
      
      let filterRegister = self.requesting.filter { (value) -> Bool in
        let (_, requestObject) = value
        return requestObject.0 != ""
      }
      
      filterRegisters = Array(filterRegister.values)
    }
    
    self.requests += filterRegisters

    self.requesting_queue_concurrent.async(flags: .barrier) {[weak self] in
      guard let `self` = self else { return }
      self.requesting.removeAll()
    }
  }
  

  private func handlerRequestPool() {
    let requestQueue = self.requests
  
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
    AppConfiguration.shared.appCoordinator.getLatestData()
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
    self.requesting_queue_concurrent.async(flags: .barrier) {[weak self] in
      guard let `self` = self else { return }

      let data = JSON(parseJSON:text)
      
      if let error = data["error"].dictionary {
        print(error)
        return
      }
      
      guard let id = data["id"].int else {
        if let method = data["method"].string, method == "notice", let params = data["params"].array, let mID = params[0].int {
          if let ids = app_data.subscribeIds, ids.values.contains(mID) {
            let index = ids.values.index(of: mID)!
            let pair = ids.keys[index]
            
            main {
              AppConfiguration.shared.appCoordinator.request24hMarkets([pair], sub: false)
            }
          }
        }
        return
      }
      
      var requestData:RequestsType?
      
      if let data = self.requesting[id.description] {
        requestData = data
      }

      if let requestData = requestData, let request = requestData.1 as? JSONRPCResponse {
        if requestData.1 is SubscribeMarketRequest {
          main {
            request.response(id)
          }
          self.requesting.removeValue(forKey: id.description)

          return
        }
        
        if let object = try? request.transferResponse(from: data["result"].object) {
          main{
            request.response(object)
          }
          self.requesting.removeValue(forKey: id.description)

        }
        else {
          main {
            request.response(data.object)
          }
          self.requesting.removeValue(forKey: id.description)

        }
      }
    }
  }
  
  func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
  }
  
}
