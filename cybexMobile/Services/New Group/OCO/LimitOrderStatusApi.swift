//
//  LimitOrderStatusApi.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/13.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import JSONRPCKit

enum LimitOrderStatusApi {
    case getMaxLimitOrderIdByTime(date: Date)
    case getLimitOrder(userId: String, lessThanOrderId: String, limit: Int)
    case getMarketLimitOrder(userId: String, asset1Id: String, asset2Id: String, lessThanOrderId: String, limit: Int)

    case getOpenedLimitOrder(userId: String)
    case getOpenedMarketLimitOrder(userId: String, asset1Id: String, asset2Id: String)

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
        }
    }

    var params: [Any] {
        switch self {
        case let .getMaxLimitOrderIdByTime(date):
            return [date.string(withFormat: "YYYY-mm-ddTHH:MM:SS")]
        case let .getLimitOrder(userId, lessThanOrderId, limit):
            return [userId, lessThanOrderId, limit]
        case let .getMarketLimitOrder(userId, asset1Id, asset2Id, lessThanOrderId, limit):
            return [userId, asset1Id, asset2Id, lessThanOrderId, limit]
        case let .getOpenedLimitOrder(userId):
            return [userId]
        case let .getOpenedMarketLimitOrder(userId, asset1Id, asset2Id):
            return [userId, asset1Id, asset2Id]
        }
    }
}

struct GetLimitOrderStatus: JSONRPCKit.Request, JSONRPCResponse {
    var response: RPCSResponse
    
    var status: LimitOrderStatusApi

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [status.name, status.params]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}
