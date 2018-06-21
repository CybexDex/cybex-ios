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
  case get_full_accounts
  case get_chain_id
  case get_objects
  case subscribe_to_market
  case get_limit_orders
  case get_balance_objects
  case get_account_by_name
  case get_required_fees
}

struct GetRequiredFees:JSONRPCKit.Request, JSONRPCResponse {
  var response: RPCSResponse
  var operationStr:String
  var assetID:String

  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.get_required_fees.rawValue, [JSON(operationStr).dictionaryObject ?? [:], assetID]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    let result = JSON(resultObject)
    if let _ = result.dictionaryObject {
      return true
    }
    
    return false
  }
}

struct GetAccountByNameRequest: JSONRPCKit.Request, JSONRPCResponse {
  var name:String
  
  var response: RPCSResponse
  
  
  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.get_account_by_name.rawValue, [name]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    let result = JSON(resultObject)
    if let _ = result.dictionaryObject {
      return true
    }
    
    return false
  }
}

typealias FullAccount = (account:Account?, balances:[Balance]?, limitOrder:[LimitOrder]?)

struct GetFullAccountsRequest: JSONRPCKit.Request, JSONRPCResponse {
  var name:String
  var response:RPCSResponse
  
  var method: String {
    return "call"
  }
  
  var parameters: Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0, dataBaseCatogery.get_full_accounts.rawValue, [[name], true]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    let result = JSON(resultObject).arrayValue
    
    let result_value:FullAccount = (nil, nil, nil)
    if result.count == 0 {
      return result_value
    }
    
    guard let full = result.first?.arrayValue[1],
      let account_dic = full["account"].dictionaryObject
      else {
        return result_value
    }
    
    let account = Account(JSON: account_dic)
    
    let balances_arr = full["balances"].arrayValue
    let limitOrder_arr = full["limit_orders"].arrayValue
    
    let balances = balances_arr.map { (obj) -> Balance in
      return Balance(JSON: obj.dictionaryObject!)!
    }
    
    let limitOrders = limitOrder_arr.map { (obj) -> LimitOrder in
      return LimitOrder(JSON: obj.dictionaryObject!)!
    }
    
    return (account, balances, limitOrders)
  }
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

struct GetObjectsRequest: JSONRPCKit.Request, JSONRPCResponse {
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
    if result.count >= 1 {
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


struct getBalanceObjectsRequest : JSONRPCKit.Request , JSONRPCResponse{
  var address : [String]
  var response: RPCSResponse
  
  var method:String{
    return "call"
  }
  
  var parameters : Any? {
    return [WebsocketService.shared.ids[apiCategory.database] ?? 0 , dataBaseCatogery.get_balance_objects.rawValue,[address]]
  }
  
  func transferResponse(from resultObject: Any) throws -> Any {
    let result = JSON(resultObject).arrayValue
    if result.count > 0 {
      var data:[LockUpAssetsMData] = []
      for i in result{
        guard let dic = i.dictionaryObject else{ return [] }
        guard let lockup = LockUpAssetsMData(JSON: dic) else{ return[] }
        data.append(lockup)
      }
      return data
    }
    return []
  }
  
}
