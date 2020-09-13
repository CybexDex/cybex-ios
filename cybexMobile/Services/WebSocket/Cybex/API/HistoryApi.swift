//
//  HistoryApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import AnyCodable

enum HistoryCatogery: String {
    case getMarketHistory
    case getFillOrderHistory //逐笔成交单
}

struct AssetPairQueryParams {
    var firstAssetId: String
    var secondAssetId: String
    var timeGap: Int
    var startTime: Date
    var endTime: Date
}

struct GetMarketHistoryRequest: Request, JSONRPCResponse {
    var queryParams: AssetPairQueryParams
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.history.rawValue),
                AnyEncodable(HistoryCatogery.getMarketHistory.rawValue.snakeCased()),
                AnyEncodable([queryParams.firstAssetId,
                 queryParams.secondAssetId,
                 queryParams.timeGap,
                 queryParams.startTime.iso8601,
                 queryParams.endTime.iso8601])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? [[String: Any]] {
            return response.map { data in
                return Bucket.deserialize(from: data)
            }
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct GetFillOrderHistoryRequest: Request, JSONRPCResponse {
    var pair: Pair
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(ApiCategory.history.rawValue),
                AnyEncodable(HistoryCatogery.getFillOrderHistory.rawValue.snakeCased()),
                AnyEncodable([pair.base, pair.quote, 40])]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}
