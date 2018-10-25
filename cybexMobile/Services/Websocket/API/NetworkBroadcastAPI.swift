//
//  NetworkBroadcastAPI.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import JSONRPCKit
import SwiftyJSON

enum broadcastCatogery: String {
  case broadcast_transaction_with_callback
}

struct BroadcastTransactionRequest: JSONRPCKit.Request, JSONRPCResponse {
  var response: RPCSResponse

  var jsonstr: String
  var method: String {
    return "call"
  }

  var parameters: Any? {
    return [apiCategory.network_broadcast, broadcastCatogery.broadcast_transaction_with_callback.rawValue, [CybexWebSocketService.shared.idGenerator.currentId + 1, JSON(parseJSON: jsonstr).dictionaryObject ?? [:]]]
  }

  func transferResponse(from resultObject: Any) throws -> Any {
    return resultObject
  }
}
