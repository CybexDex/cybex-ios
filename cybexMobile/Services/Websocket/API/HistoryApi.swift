//
//  HistoryApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import JSONRPCKit
import SwiftyJSON

enum historyCatogery:String {
  case get_market_history
  case get_fill_order_history
  case get_account_history
}

struct AssetPairQueryParams {
  var firstAssetId:String
  var secondAssetId:String
  var timeGap:Int
  var startTime:Date
  var endTime:Date
}

struct GetAccountHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
  var accountID:String
  var response:RPCSResponse
  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.history] ?? 0, historyCatogery.get_account_history.rawValue, [accountID, "1.11.0", "100", "1.11.0"]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    if let response = resultObject as? [[String: Any]] {
      var fillOrders: [FillOrder] = []
      
      for i in response {
        if let op = i["op"] as? [Any], let opcode = op[0] as? Int, opcode == ChainTypesOperations.fill_order.rawValue, var operation = op[1] as? [String: Any],let blockNum = i["block_num"] {
          operation["block_num"] = blockNum
          if let fillorder = FillOrder(JSON: operation) {
            fillOrders.append(fillorder)
          }
        }
      }
      return fillOrders
    } else {
      throw CastError(actualValue: resultObject, expectedType: Response.self)
    }
  }
}

struct GetMarketHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
  var queryParams:AssetPairQueryParams
  var response:RPCSResponse

  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.history] ?? 0, historyCatogery.get_market_history.rawValue, [queryParams.firstAssetId, queryParams.secondAssetId, queryParams.timeGap, queryParams.startTime.iso8601, queryParams.endTime.iso8601]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    if let response = resultObject as? [[String: Any]] {
      return response.map { data in
        return Bucket(JSON:data)!
      }
    } else {
      throw CastError(actualValue: resultObject, expectedType: Response.self)
    }
  }
}


struct GetFillOrderHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
  var pair:Pair
  var response:RPCSResponse
  
  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.history] ?? 0, historyCatogery.get_fill_order_history.rawValue, [pair.base, pair.quote, 40]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    let result = JSON(resultObject).arrayValue
   
    var data:[JSON] = []

    for re in result {
      data.append([re["op"]["pays"], re["op"]["receives"], re["time"]])
    }
    return data
  }
}
