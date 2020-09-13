//
//  DataBaseApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import AnyCodable

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
    case getTickerBatch
    case getBlockHeader
    case getRecentTransactionById
    case getKeyReferences
    case getAccountTokenAge
}

struct GetRequiredFees: Request, JSONRPCResponse {
    var response: RPCSResponse
    var operationStr: String
    var assetID: String
    var operationID: Int

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                AnyEncodable(DataBaseCatogery.getRequiredFees.rawValue.snakeCased()),
                AnyEncodable([[[operationID, JSON(parseJSON: operationStr).dictionaryObject ?? [:]]], assetID])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject)
        if let data = result.arrayObject as? [[String: Any]] {
            return data.compactMap({Fee.deserialize(from: $0)})
        }
        return []
    }
}

struct GetAccountByNameRequest: Request, JSONRPCResponse {
    var name: String

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getAccountByName.rawValue.snakeCased()),
                                          AnyEncodable([name])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject)
        if result.dictionaryObject != nil {
            return true
        }

        return false
    }
}

struct GetFullAccountsRequest: Request, JSONRPCResponse {
    var name: String
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getFullAccounts.rawValue.snakeCased()),
                                          AnyEncodable([[name], true])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject).arrayValue

        let resultValue: FullAccount? = nil

        if result.count == 0 {
            return resultValue as Any
        }

        guard let arr = result.first?.arrayValue, arr.count >= 2 else {
            return resultValue as Any
        }
        let full = arr[1]
        return FullAccount.deserialize(from: full.dictionaryObject) as Any
    }
}

struct GetChainIDRequest: Request, JSONRPCResponse {
    var method: String {
        return "call"
    }
    var response: RPCSResponse

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getChainId.rawValue.snakeCased()),
                                          AnyEncodable([])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? String {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct GetObjectsRequest: Request, JSONRPCResponse {
    var ids: [String]
    var refLib: Bool = false

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getObjects.rawValue.snakeCased()),
                                          AnyEncodable([ids])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if var result = resultObject as? [Any] {
            result = result.filter { (val) -> Bool in
                return val is [String: Any]
            }

            if let response = result as? [[String: Any]] {
                if ids.first == ObjectID.dynamicGlobalPropertyObject {
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

struct LookupAssetSymbolsRequest: Request, JSONRPCResponse {
    var names: [String]

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.lookupAssetSymbols.rawValue.snakeCased()),
                                          AnyEncodable([names])]
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

struct SubscribeMarketRequest: Request, RevisionRequest, JSONRPCResponse {
    var ids: [String]

    var method: String {
        return "call"
    }

    var response: RPCSResponse

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.subscribeToMarket.rawValue.snakeCased()),
                                          AnyEncodable([CybexWebSocketService.shared.idGenerator.currentId + 1, ids[0], ids[1]])]
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

struct GetLimitOrdersRequest: Request, JSONRPCResponse {
    var pair: Pair
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getLimitOrders.rawValue.snakeCased()),
                                          AnyEncodable([pair.base, pair.quote, 500])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}

struct GetBalanceObjectsRequest: Request, JSONRPCResponse {
    var address: [String]
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getBalanceObjects.rawValue.snakeCased()),
                                          AnyEncodable([address])]
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

struct GetBlockRequest: Request, JSONRPCResponse {
    var response: RPCSResponse

    var blockNum: Int
    var method: String {
        return "call"
    }
    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getBlock.rawValue.snakeCased()),
                                          AnyEncodable([blockNum])]
    }
    func transferResponse(from resultObject: Any) throws -> Any {
        let data = JSON(resultObject).dictionaryValue
        return data["timestamp"]?.stringValue ?? ""
    }
}

struct GetTickerRequest: Request, JSONRPCResponse {
    var baseName: String
    var quoteName: String
    var response: RPCSResponse
    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getTicker.rawValue.snakeCased()),
                                          AnyEncodable([baseName, quoteName])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let data = JSON(resultObject).dictionaryObject
        if let ticker = Ticker.deserialize(from: data) {
            return ticker
        }

        return Ticker()
    }
}

struct GetTickerBatchRequest: Request, JSONRPCResponse {
    var pairs: [Pair]

    var response: RPCSResponse
    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getTickerBatch.rawValue.snakeCased()),
                                          AnyEncodable([pairs.map({[$0.base, $0.quote]})])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let data = JSON(resultObject).arrayObject {
            var tickers: [Ticker] = []
            for o in data {
                if let ticker = Ticker.deserialize(from: o as? [String: Any]) {
                    tickers.append(ticker)
                }
            }

            return tickers
        }

        return []
    }
}

struct GetBlockHeaderRequest: Request, JSONRPCResponse {
    var blockNum: String

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getBlockHeader.rawValue.snakeCased()),
                                          AnyEncodable([blockNum])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let data = JSON(resultObject)

        return data["previous"].stringValue
    }
}

struct GetRecentTransactionById: Request, JSONRPCResponse {
    var id: String

    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.database.rawValue),
                             AnyEncodable(DataBaseCatogery.getRecentTransactionById.rawValue.snakeCased()),
                             AnyEncodable([id])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}
