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

enum historyCatogery: String {
    case get_market_history
    case get_fill_order_history
    case get_account_history
}

struct AssetPairQueryParams {
    var firstAssetId: String
    var secondAssetId: String
    var timeGap: Int
    var startTime: Date
    var endTime: Date
}

struct GetAccountHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
    var accountID: String
    var response: RPCSResponse
    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [apiCategory.history, historyCatogery.get_account_history.rawValue, [accountID, objectID.operation_history_object.rawValue, "100", objectID.operation_history_object.rawValue]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
            var fillOrders: [FillOrder] = []
            var transferRecords: [TransferRecord] = []
            for i in response {
                if let op = i["op"] as? [Any], let opcode = op[0] as? Int, var operation = op[1] as? [String: Any], let blockNum = i["block_num"] {
                    operation["block_num"] = blockNum
                    if opcode == ChainTypesOperations.fill_order.rawValue {
                        if let fillorder = FillOrder(JSON: operation) {
                            fillOrders.append(fillorder)
                        }
                    } else if opcode == ChainTypesOperations.transfer.rawValue {
                        // 转账记录
                        if let extensions = operation["extensions"] as? [Any], extensions.count > 0, let lockUpInfos = extensions[0] as? [Any], lockUpInfos.count >= 2, let lockUpInfo = lockUpInfos[1] as? [String: Any] {
                            operation["vesting_period"] = lockUpInfo["vesting_period"]
                            operation["public_key"] = lockUpInfo["public_key"]
                        }

                        if let transferRecord = TransferRecord.deserialize(from: operation) {
                            transferRecords.append(transferRecord)
                        }
                    }
                }
            }
            return (fillOrders, transferRecords)
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct GetMarketHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
    var queryParams: AssetPairQueryParams
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [apiCategory.history, historyCatogery.get_market_history.rawValue, [queryParams.firstAssetId, queryParams.secondAssetId, queryParams.timeGap, queryParams.startTime.iso8601, queryParams.endTime.iso8601]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
            return response.map { data in
                return Bucket(JSON: data)!
            }
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct GetFillOrderHistoryRequest: JSONRPCKit.Request, JSONRPCResponse {
    var pair: Pair
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [apiCategory.history, historyCatogery.get_fill_order_history.rawValue, [pair.base, pair.quote, 40]]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        let result = JSON(resultObject).arrayValue

        var data: [JSON] = []

        for re in result {
            data.append([re["op"]["pays"], re["op"]["receives"], re["time"]])
        }
        return data
    }
}
