//
//  DataBaseApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import JSONRPCKit
import SwiftyJSON

enum dataBaseCatogery:String {
  case get_chain_id
  case get_objects
  case subscribe_to_market
  case get_limit_orders
}

struct GetChainIDRequest: JSONRPCKit.Request, JSONRPCResponse {
  var method: String {
    return "call"
  }
  var response:RPCSResponse
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.get_chain_id.rawValue, []]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    if let response = resultObject as? String {
      return response
    } else {
      throw CastError(actualValue: resultObject, expectedType: Response.self)
    }
  }
}

struct GetAssetRequest: JSONRPCKit.Request, JSONRPCResponse {
  var ids:[String]
  var response:RPCSResponse
  
  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.get_objects.rawValue, [ids]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    if let response = resultObject as? [[String: Any]] {
      return response.map { data in
        
        return AssetInfo(JSON:data)!
      }
    } else {
      throw CastError(actualValue: resultObject, expectedType: Response.self)
    }
  
  }
}

struct SubscribeMarketRequest: JSONRPCKit.Request, RevisionRequest, JSONRPCResponse {
  var ids:[String]
  
  var method: String {
    return "call"
  }
  
  var response:RPCSResponse

  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.subscribe_to_market.rawValue, [WebsocketService.shared.idGenerator.currentId + 1, ids[0], ids[1]]]
  }
  
  func revisionParameters(_ data:Any) -> Any {
    var data = JSON(data)
    
    if var params = data["params"].array, let id = data["id"].int , let event = params[1].string, event == dataBaseCatogery.subscribe_to_market.rawValue, var subParams = params[2].array {
      subParams[0] = JSON(id)
      params[2] = JSON(subParams)
      data["params"] = JSON(params)
    }

    return data
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
      return resultObject
  }
}

struct getLimitOrdersRequest: JSONRPCKit.Request, JSONRPCResponse {
  var pair:Pair
  var response:RPCSResponse
  
  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.get_limit_orders.rawValue, [pair.base, pair.quote, 20]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    let result = JSON(resultObject).arrayValue
    if result.count > 1 {
      var data:[LimitOrder] = []
      for i in result {
        let order = try! LimitOrder(JSON: i.dictionaryObject!)
        data.append(order)
      }
      
      return data
    }
    else {
      return []
    }
  }
}
