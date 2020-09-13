//
//  JsonRPCService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import AnyCodable

enum ApiCategory: String {
    case login
    case database
    case networkBroadcast
    case history
    case none
}

struct CastError<ExpectedType>: Error {
    let actualValue: Any
    let expectedType: ExpectedType.Type
}

public struct JsonIdGenerator: IdGenerator {

    var currentId = 1

    public init() {}

    public mutating func next() -> Id {
        defer {
            currentId += 1
        }

        return .number(currentId)
    }
}

typealias RPCSResponse = (Any) -> Void

protocol JSONRPCResponse {
    var response: RPCSResponse { get }
    func response(from resultObject: Any) throws -> Any//不用实现
    func transferResponse(from resultObject: Any) throws -> Any
}

protocol RevisionRequest {
    func revisionParameters(_ data: Any) -> Any
}

extension Request {
    var method: String {
        return "call"
    }

    var digist: String {
        if var data = parameters as? [Any] {
            data.removeFirst()

            return data.reduce("", { (last, cur) -> String in
                return last + "\(cur)"
            })
        }
        return ""
    }

    func response(from resultObject: Any) throws -> Any {
        return resultObject
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        return resultObject
    }
}

struct RegisterIDRequest : JSONRPCResponse, Request  {
    
    var api: ApiCategory
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(1),
                             AnyEncodable(api.rawValue.snakeCased()),
                                          AnyEncodable([])]
    }

    var digist: String {
        return ""
    }

    func transferResponse(from resultObject: Any) throws -> Any {
        if let response = resultObject as? Int {
            return response
        } else {
            throw CastError(actualValue: resultObject, expectedType: Response.self)
        }
    }
}

struct LoginRequest: Request, JSONRPCResponse {
    let username: String
    let password: String
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var digist: String {
        return ""
    }
    
    var parameters: Encodable? {
        return [AnyEncodable(1), AnyEncodable(ApiCategory.login.rawValue), AnyEncodable([username, password])]
    }
}

struct LoginRequest2: Request, JSONRPCResponse {
    let username: String
    let password: String
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Encodable? {
        return [AnyEncodable(1), AnyEncodable(ApiCategory.login.rawValue), AnyEncodable([username, password])]
    }
}
