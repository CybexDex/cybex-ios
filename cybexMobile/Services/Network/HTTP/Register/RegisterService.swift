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

enum RegisterApi {
    case getPinCode

    case register(_ pinID: String, captcha: String, name: String, keys: AccountKeys)
}

struct RegisterService {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://faucet.cybex.io")!
        static let devURL = URL(string: "https://faucet.51nebula.com")!
        static var uatURL = URL(string: "https://uatfaucet.51nebula.com")!
    }

    static let provider = MoyaProvider<RegisterApi>(callbackQueue: nil, manager: defaultManager(),
                                                        plugins: [NetworkLoggerPlugin(verbose: true)],
                                                        trackInflights: false)

    static func request(
        target: RegisterApi,
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

extension RegisterApi : TargetType {
    var baseURL: URL {
        return RegisterService.Config.currentEnv
    }

    var path: String {
        switch self {
        case .getPinCode:
            return "/captcha"
        case .register:
            return "/register"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPinCode:
            return .get
        case .register:
            return .post
        }
    }

    var urlParameters: [String: Any] {
        switch self {
        default:
            return [:]
        }
    }

    var parameters: [String: Any] {
        switch self {
        case let .register(pinID, captcha, name, keys):
            return ["cap": ["id": pinID, "captcha": captcha],
             "account": ["name": name,
                         "owner_key": keys.ownerKey?.publicKey,
                         "active_key": keys.activeKey?.publicKey,
                         "memo_key": keys.memoKey?.publicKey,
                         "refcode": "",
                         "referrer": ""]]
        default:
            return [:]
        }
    }

    var task: Task {
        switch self {
        default:
            if method == .get {
                return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
            } else {
                return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            }
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
