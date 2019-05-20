//
//  IMService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/10.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire
import SwiftyUserDefaults

enum IMAPI {
    case messageCount(_ channel: String)
}

struct IMService {
    enum Config: NetworkHTTPEnv {
        static let productURL = URL(string: "https://chat.cybex.io")!
        static let devURL = URL(string: "http://47.91.242.71:9099")!
        static let uatURL = URL(string: "http://47.91.242.71:9099")!
    }

    static let provider = MoyaProvider<IMAPI>(callbackQueue: nil, manager: defaultManager(),
                                                    plugins: [NetworkLoggerPlugin(verbose: true)],
                                                    trackInflights: false)

    static func request(
        target: IMAPI,
        success successCallback: @escaping (JSON) -> Void,
        error errorCallback: @escaping (CybexError) -> Void,
        failure failureCallback: @escaping (CybexError) -> Void
        ) {

        provider.request(target) { (result) in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    if json["code"].intValue == 0 {
                        successCallback(json)
                    } else {
                        errorCallback(CybexError.serviceFriendlyError(code: json["code"].intValue,
                                                                      desc: json["data"]))
                    }
                } catch let serverError {
                    if let json = try? JSON(response.mapJSON()) {
                        if json["code"].intValue != 0 {
                            errorCallback(CybexError.serviceFriendlyError(code: json["code"].intValue,
                                                                          desc: json["data"]))
                        } else {
                            failureCallback(CybexError.serviceHTTPError(desc: serverError.localizedDescription))
                        }
                    }
                }
            case let .failure(error):
                failureCallback(CybexError.serviceHTTPError(desc: error.localizedDescription))
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

extension IMAPI: TargetType {
    var baseURL: URL {
        return IMService.Config.currentEnv
    }

    var path: String {
        switch self {
        case .messageCount:
            return "/lastestMsgID"
        }
    }

    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var urlParameters: [String: Any] {
        switch self {
        case let .messageCount(channel):
            return ["channel": channel]
        }
    }

    var parameters: [String: Any] {
        switch self {

        default:
            return [:]
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
