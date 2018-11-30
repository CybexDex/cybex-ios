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

enum DataBaseCatogery: String {
    case getFullAccounts
    case getChainId
    case getObjects
    case subscribeToMarket
    case getLimitOrders
    case getBalanceObjects
    case getAccountByName
    case getRequiredFees
    case getBlock
    case getTicker
}

struct GetRequiredFees: JSONRPCKit.Request, JSONRPCResponse {
    var response: RPCSResponse
    var operationStr: String
    var assetID: String
    var operationID: ChainTypesOperations

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database,
                DataBaseCatogery.getRequiredFees.rawValue.snakeCased(),
                [[[operationID.rawValue, JSON(parseJSON: operationStr).dictionaryObject ?? [:]]], assetID]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject)
        if let data = result.arrayObject as? [[String: Any]] {
            return data.compactMap({Fee.deserialize(from: $0)})
        }
        return []
    }
}

struct GetAccountByNameRequest: JSONRPCKit.Request, JSONRPCResponse {
    var name: String

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getAccountByName.rawValue.snakeCased(), [name]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject)
        if result.dictionaryObject != nil {
            return true
        }

        return false
    }
}

typealias FullAccount = (account: Account?, balances: [Balance]?, limitOrder: [LimitOrder]?)

struct GetFullAccountsRequest: JSONRPCKit.Request, JSONRPCResponse {
    var name: String
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getFullAccounts.rawValue.snakeCased(), [[name], true]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject).arrayValue

        let resultValue: FullAccount = (nil, nil, nil)
        if result.count == 0 {
            return resultValue
        }

        guard let full = result.first?.arrayValue[1],
            let accountDic = full["account"].dictionaryObject
            else {
                return resultValue
        }

        let account = Account.deserialize(from: accountDic)

        let balancesArr = full["balances"].arrayValue
        let limitOrderArr = full["limit_orders"].arrayValue

        let balances = balancesArr.map { (obj) -> Balance in
            return Balance.deserialize(from: obj.dictionaryObject!) ?? Balance()
        }

        let limitOrders = limitOrderArr.map { (obj) -> LimitOrder in
            return LimitOrder.deserialize(from: obj.dictionaryObject!) ?? LimitOrder()
        }

        return (account, balances, limitOrders)
    }
}

struct GetChainIDRequest: JSONRPCKit.Request, JSONRPCResponse {
    var method: String {
        return "call"
    }
    var response: RPCSResponse

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getChainId.rawValue.snakeCased(), []]
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
    var ids: [String]
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getObjects.rawValue.snakeCased(), [ids]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
            if ids.first == "2.1.0"{
                var headBlockId = ""
                var headBlockNumber = ""
                for res in response.first! {
                    if res.key == "head_block_id"{
                        headBlockId = String(describing: res.value)
                    } else if res.key == "head_block_number"{
                        headBlockNumber = String(describing: res.value)
                    }
                }
                return (block_id:headBlockId, block_num:headBlockNumber)
            }

            return response.map { data in

                return AssetInfo.deserialize(from: data)
            }
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }

    }
}

struct SubscribeMarketRequest: JSONRPCKit.Request, RevisionRequest, JSONRPCResponse {
    var ids: [String]

    var method: String {
        return "call"
    }

    var response: RPCSResponse

    var parameters: Any? {
        return [ApiCategory.database,
                DataBaseCatogery.subscribeToMarket.rawValue.snakeCased(),
                [CybexWebSocketService.shared.idGenerator.currentId + 1, ids[0], ids[1]]]
    }

    func revisionParameters(_ data: Any) -> Any {
        var data = JSON(data)

        if var params = data["params"].array,
            let marketId = data["id"].int,
            let event = params[1].string,
            event == DataBaseCatogery.subscribeToMarket.rawValue.snakeCased(),
            var subParams = params[2].array {
            subParams[0] = JSON(marketId)
            params[2] = JSON(subParams)
            data["params"] = JSON(params)
        }

        return data
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}

struct GetLimitOrdersRequest: JSONRPCKit.Request, JSONRPCResponse {
    var pair: Pair
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database,
                DataBaseCatogery.getLimitOrders.rawValue.snakeCased(),
                [pair.base, pair.quote, 500]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject).arrayValue
        if result.count >= 1 {
            var data: [LimitOrder] = []
            for index in result {
                if let order = LimitOrder.deserialize(from: index.dictionaryObject!) {
                    data.append(order)
                }
            }
            return data
        } else {
            return []
        }
    }
}

struct GetBalanceObjectsRequest: JSONRPCKit.Request, JSONRPCResponse {
    var address: [String]
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getBalanceObjects.rawValue.snakeCased(), [address]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject).arrayValue
        if result.count > 0 {
            var data: [LockUpAssetsMData] = []
            for index in result {
                guard let dic = index.dictionaryObject else { return [] }
                guard let lockup = LockUpAssetsMData.deserialize(from: dic) else { return[] }
                data.append(lockup)
            }
            return data
        }
        return []
    }
}

struct GetBlockRequest: JSONRPCKit.Request, JSONRPCResponse {
    var response: RPCSResponse

    var blockNum: Int
    var method: String {
        return "call"
    }
    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getBlock.rawValue.snakeCased(), [blockNum]]
    }
    func transferResponse(from resultObject: Any) throws -> Any {
        let data = JSON(resultObject).dictionaryValue
        return data["timestamp"]?.stringValue ?? ""
    }
}

struct GetTickerRequest: JSONRPCKit.Request, JSONRPCResponse {
    var baseName: String
    var quoteName: String
    var response: RPCSResponse
    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getTicker.rawValue.snakeCased(), [baseName, quoteName]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let data = JSON(resultObject).dictionaryObject
        if let ticker = Ticker.deserialize(from: data) {
            return ticker
        }

        return Ticker()
    }
}
