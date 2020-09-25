//
//  NetworkBroadcastAPI.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import AnyCodable

enum BroadcastCatogery: String {
    case broadcastTransactionWithCallback
}

struct BroadcastTransactionRequest: Request, JSONRPCResponse {
    var response: RPCSResponse

    var jsonstr: String
    var method: String {
        return "call"
    }

    var parameters: Encodable? {

        return [AnyEncodable(ApiCategory.networkBroadcast.rawValue.snakeCased()),
                AnyEncodable(BroadcastCatogery.broadcastTransactionWithCallback.rawValue.snakeCased()),
                AnyEncodable([CybexWebSocketService.shared.idGenerator.currentId + 1,
                 JSON(parseJSON: jsonstr).dictionaryObject ?? [:]])
        ]
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}
