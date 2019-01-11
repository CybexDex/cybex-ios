//
//  JsonRPCService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import JSONRPCKit

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

extension JSONRPCKit.Request {
    typealias Response = Any

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

struct RegisterIDRequest: JSONRPCKit.Request, JSONRPCResponse {
    var api: ApiCategory
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [ApiCategory.none, api.rawValue.snakeCased(), []]
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

struct LoginRequest: JSONRPCKit.Request, JSONRPCResponse {
    let username: String
    let password: String
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var digist: String {
        return ""
    }

    var parameters: Any? {
        return [1, ApiCategory.login.rawValue, [username, password]]
    }
}

struct LoginRequest2: JSONRPCKit.Request, JSONRPCResponse {
    let username: String
    let password: String
    var response: RPCSResponse

    var method: String {
        return "call"
    }

    var parameters: Any? {
        return [1, ApiCategory.login.rawValue, [username, password]]
    }
}
