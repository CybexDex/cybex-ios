//
//  LimitOrderStatusApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/13.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import AnyCodable

enum LimitOrderStatusApi {
    case getMaxLimitOrderIdByTime(date: Date)
    case getLimitOrder(userId: String, lessThanOrderId: String, limit: Int)
    case getMarketLimitOrder(userId: String, asset1Id: String, asset2Id: String, lessThanOrderId: String, limit: Int)

    case getOpenedLimitOrder(userId: String)
    case getOpenedMarketLimitOrder(userId: String, asset1Id: String, asset2Id: String)

    case addFilteredMarket(pairs: [Pair])
    case getFilteredLimitOrder(userId: String, lessThanOrderId: String, limit: Int)
    case clearFilteredMarket

    var name: String {
        switch self {
        case .getMaxLimitOrderIdByTime:
            return "get_limit_order_id_by_time"
        case .getLimitOrder:
            return "get_limit_order_status"
        case .getMarketLimitOrder:
            return "get_market_limit_order_status"
        case .getOpenedLimitOrder:
            return "get_opened_limit_order_status"
        case .getOpenedMarketLimitOrder:
            return "get_opened_market_limit_order_status"
        case .getFilteredLimitOrder:
            return "get_filtered_limit_order_status"
        case .addFilteredMarket:
            return "add_filtered_market"
        case .clearFilteredMarket:
            return "clear_filtered_market"
        }
    }

    var params: AnyEncodable {
        switch self {
        case let .getMaxLimitOrderIdByTime(date):
            return [date.string(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS")]
        case let .getLimitOrder(userId, lessThanOrderId, limit):
            return [userId, lessThanOrderId, limit]
        case let .getMarketLimitOrder(userId, asset1Id, asset2Id, lessThanOrderId, limit):
            return [userId, asset1Id, asset2Id, lessThanOrderId, limit]
        case let .getOpenedLimitOrder(userId):
            return [userId]
        case let .getOpenedMarketLimitOrder(userId, asset1Id, asset2Id):
            return [userId, asset1Id, asset2Id]
        case let .addFilteredMarket(pairs):
            return [pairs.map { [$0.base, $0.quote] }]
        case let .getFilteredLimitOrder(userId, lessThanOrderId, limit):
            return  [userId, lessThanOrderId, limit, true]
        case .clearFilteredMarket:
            return []
        }
    }
}

struct GetLimitOrderStatus: Request, JSONRPCResponse {
    var response: RPCSResponse
    
    var status: LimitOrderStatusApi

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(status.name), AnyEncodable(status.params)]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }

}
