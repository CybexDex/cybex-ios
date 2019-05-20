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
    case lookupAssetSymbols
    case subscribeToMarket
    case getLimitOrders
    case getBalanceObjects
    case getAccountByName
    case getRequiredFees
    case getBlock
    case getTicker
    case getBlockHeader
    case getRecentTransactionById
    case getKeyReferences
    case getAccountTokenAge
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

        let resultValue: FullAccount? = nil

        if result.count == 0 {
            return resultValue as Any
        }

        guard let full = result.first?.arrayValue[1] else {
            return resultValue as Any
        }

        return FullAccount.deserialize(from: full.dictionaryObject) as Any
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
    var refLib: Bool = false

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getObjects.rawValue.snakeCased(), [ids]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if var result = resultObject as? [Any] {
            result = result.filter { (val) -> Bool in
                return val is [String: Any]
            }

            if let response = result as? [[String: Any]] {
                if ids.first == ObjectID.dynamicGlobalPropertyObject.rawValue {
                    var headBlockId = ""
                    var headBlockNumber = ""
                    for res in response.first! {
                        if refLib {
                            if res.key == "last_irreversible_block_num", let value = res.value as? Int {
                                headBlockNumber = String(describing: value)
                            }
                        }
                        else {
                            if res.key == "head_block_id" {
                                headBlockId = String(describing: res.value)
                            } else if res.key == "head_block_number" {
                                headBlockNumber = String(describing: res.value)
                            }
                        }
                    }
                    return (block_id:headBlockId, block_num:headBlockNumber)
                }

                return response.map { data in
                    return AssetInfo.deserialize(from: data)
                }
            }
        } else {
            return resultObject
        }

        return resultObject
    }
}

struct LookupAssetSymbolsRequest: JSONRPCKit.Request, JSONRPCResponse {
    var names: [String]

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.lookupAssetSymbols.rawValue.snakeCased(), [names]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
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
        return resultObject
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

struct GetBlockHeaderRequest: JSONRPCKit.Request, JSONRPCResponse {
    var blockNum: String

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getBlockHeader.rawValue.snakeCased(), [blockNum]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let data = JSON(resultObject)

        return data["previous"].stringValue
    }
}

struct GetRecentTransactionById: JSONRPCKit.Request, JSONRPCResponse {
    var id: String

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.database, DataBaseCatogery.getRecentTransactionById.rawValue.snakeCased(), [id]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}
