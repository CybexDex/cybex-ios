//
//  BatchElement.swift
//  JSONRPCKit
//
//  Created by ishkawa on 2016/07/27.
//  Copyright © 2016年 Shinichiro Oba. All rights reserved.
//

import Foundation

internal protocol BatchElementProcotol: Encodable {
    associatedtype R: Request

    var decoder: DecoderType { get set }
    var request: R { get }
    var version: String { get }
    var id: Id? { get }
}

internal extension BatchElementProcotol {
    /// - Throws: JSONRPCError
    func response(from data: Data) throws -> R.Response {
        switch result(from: data) {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    /// - Throws: JSONRPCError
    func response(fromArray data: Data) throws -> R.Response {
        switch result(fromArray: data) {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func result(from data: Data) -> Result<R.Response, JSONRPCError> {

        var response: JSONRPCResponseResult<R.Response>
        do {
            response = try decoder.decode(JSONRPCResponseResult<R.Response>.self, from: data)
        } catch let error as JSONRPCError {
            return .failure(error)
        } catch {
            return .failure(.responseParseError(error))
        }

        return result(from: response)
    }

    func result(fromArray data: Data) -> Result<R.Response, JSONRPCError> {

        let decoder = JSONDecoder()

        var batchContainer: UnkeyedDecodingContainer
        var batchContainer2: UnkeyedDecodingContainer
        do {
            batchContainer = try decoder.decode(JSONRPCResponseResultBatchContainer.self, from: data).container
            batchContainer2 = try decoder.decode(JSONRPCResponseResultBatchContainer.self, from: data).container
        } catch let error as JSONRPCError {
            return .failure(error)
        } catch {
            return .failure(.responseParseError(error))
        }

        var response: JSONRPCResponseResult<R.Response>?
        do {
            while !batchContainer.isAtEnd {
                let decodedId = try? batchContainer.decode(IdOnly.self)
                if id == decodedId?.id {
                    response = try batchContainer2.decode(JSONRPCResponseResult<R.Response>.self)
                    break
                } else {
                    // Decode nothing to keep containers at same index
                    _ = try batchContainer2.decode(NoReply.self)
                }
            }
        } catch let error as JSONRPCError {
            return .failure(error)
        } catch {
            return .failure(.responseParseError(error))
        }

        if let response = response {
            return result(from: response)
        }
        return .failure(.responseNotFound(requestId: id))
    }

    private func result(from responseObj: JSONRPCResponseResult<R.Response>) -> Result<R.Response, JSONRPCError> {


        let receivedVersion = responseObj.jsonrpc
        guard version == receivedVersion else {
            return .failure(.unsupportedVersion(receivedVersion))
        }

        guard id == responseObj.id else {
            return .failure(.responseNotFound(requestId: id))
        }


        switch (responseObj.result, responseObj.error) {
        case (nil, let err?):
            return .failure(.responseError(code: err.code, message: err.message, data: err.data))
        case (let res?, nil):
            return .success(res)
        default:
            return .failure(.missingBothResultAndError)
        }
    }
}

private struct IdOnly: Decodable {
    let id: Id?
}

private struct JSONRPCResponseResultBatchContainer: Decodable {
    let container: UnkeyedDecodingContainer

    init(from decoder: Decoder) throws {
        container = try decoder.unkeyedContainer()
    }
}

private struct JSONRPCResponseResult<ResultObject: Decodable>: Decodable {
    let id: Id
    let jsonrpc: String
    let result: ResultObject?
    let error: JSONRPCErrorResponse?

    private enum CodingKeys: String, CodingKey {
        case id, jsonrpc, result, error
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            id = try container.decode(Id.self, forKey: .id)
            jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        } catch {
            throw JSONRPCError.responseParseError(error)
        }

        do {
            result = try container.decodeIfPresent(ResultObject.self, forKey: .result)
        } catch {
            throw JSONRPCError.resultObjectParseError(error)
        }
        do {
            error = try container.decodeIfPresent(JSONRPCErrorResponse.self, forKey: .error)
        } catch {
            throw JSONRPCError.errorObjectParseError(error)
        }
    }
}

private struct JSONRPCErrorResponse: Decodable {
    let code: Int
    let message: String
    let data: Decoder

    private enum CodingKeys: String, CodingKey {
        case code, message, data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        code = try container.decode(Int.self, forKey: .code)
        message = try container.decode(String.self, forKey: .message)
        data = try container.superDecoder(forKey: .data)
    }
}

internal extension BatchElementProcotol where R.Response == NoReply {
    /// - Throws: JSONRPCError
    func response(from data: Data) throws -> R.Response {
        return NoReply()
    }

    /// - Throws: JSONRPCError
    func response(fromArray data: Data) throws -> R.Response {
        return NoReply()
    }

    func result(from data: Data) -> Result<R.Response, JSONRPCError> {
        return .success(NoReply())
    }

    func result(fromArray data: Data) -> Result<R.Response, JSONRPCError> {
        return .success(NoReply())
    }
}

public struct BatchElement<R: Request>: BatchElementProcotol {
    var decoder: DecoderType = JSONDecoder()

    public let request: R
    public let version: String
    public let id: Id?

    public init(request: R, version: String, id: Id) {
        let id: Id? = request.isNotification ? nil : id
        
        self.request = request
        self.version = version
        self.id = id
    }

    private enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case id
        case params
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(version, forKey: .jsonrpc)
        try container.encode(request.method, forKey: .method)
        try request.extendedFields?.encode(to: encoder)

        if let params = request.parameters {
            let paramsEncoder = container.superEncoder(forKey: .params)
            try params.encode(to: paramsEncoder)
        }
    }
}

