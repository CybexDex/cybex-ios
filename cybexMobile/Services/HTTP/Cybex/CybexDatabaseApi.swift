//
//  CybexDatabaseApi.swift
//  CybexTicket
//
//  Created by koofrank on 2019/1/13.
//  Copyright © 2019 com.nbltrustdev. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire

enum DatabaseApi {
    case getAccount(name: String)
    case lookupSymbol(name: String)
    case getRecentTransactionBy(_ id: String)
}

struct CybexDatabaseApiService {
    enum Config {
        static let productURL = URL(string: "https://hongkong.cybex.io")! // https://hongkong.cybex.io
        static let devURL = URL(string: "https://hangzhou.51nebula.com")! //http://47.100.98.113:38090
    }

    static let provider = MoyaProvider<DatabaseApi>(callbackQueue: nil, manager: defaultManager(),
                                                    plugins: [NetworkLoggerPlugin(verbose: true)],
                                                    trackInflights: false)

    static func request(
        target: DatabaseApi,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (JSON) -> Void,
        failure failureCallback: @escaping (Error) -> Void
        ) {

        provider.request(target) { (result) in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    if json["error"].dictionaryObject == nil {
                        successCallback(json["result"])
                    } else {
                        errorCallback(json["error"])
                    }
                } catch let serverError {
                    if let json = try? JSON(response.mapJSON()) {
                        if json["error"].dictionaryObject == nil {
                            errorCallback(json["error"])
                        } else {
                            failureCallback(serverError)
                        }
                    }
                }
            case let .failure(error):
                failureCallback(error)
            }
        }
    }

    static func defaultManager() -> Alamofire.SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 15

        let manager = Alamofire.SessionManager(configuration: configuration)
        manager.startRequestsImmediately = false
        return manager
    }
}

extension DatabaseApi : TargetType {
    var baseURL: URL {
        return CybexDatabaseApiService.Config.productURL
    }

    var path: String {
        return ""
    }

    var apiMethod: String {
        switch self {
        case .getAccount(name: _):
            return DataBaseCatogery.getFullAccounts.rawValue.snakeCased()
        case .lookupSymbol(name: _):
            return DataBaseCatogery.lookupAssetSymbols.rawValue.snakeCased()
        case .getRecentTransactionBy(_):
            return DataBaseCatogery.getRecentTransactionById.rawValue.snakeCased()
        }
    }

    var method: Moya.Method {
        return .post
    }

    var urlParameters: [String: Any] {
        switch self {
        default:
            return [:]
        }
    }

    var parameters: [String: Any] {
       return ["jsonrpc": "2.0", "method": apiMethod, "params": wrapParams, "id": 1]
    }

    var wrapParams: Any {
        switch self {
        case let .getAccount(name: name):
            return [[name], false]
        case let .lookupSymbol(name: name):
            return [[name]]
        case let .getRecentTransactionBy(id: id):
            return [id]
        }
    }

    var task: Task {
        switch self {
        default:
            return .requestCompositeParameters(bodyParameters: parameters,
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: urlParameters)
        }
    }

    var sampleData: Data {
        if let data = try? JSON(parameters).rawData() {
            return data
        }
        return Data()
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}

