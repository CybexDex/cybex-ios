//
//  Gateway2Service.swift
//  cybexMobile
//
//  Created by koofrank on 2019/3/28.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire
import SwiftyUserDefaults
import cybex_ios_core_cpp

enum GatewayAPI {
    case assetLists
    case asset(name: String)
    case validateAddress(assetName: String, address: String)

    case topUPAddress(assetName: String, userName: String)
    case transactions(fundType: FundType, assetName: String, userName: String, fromId: Int?)
    case assetsOfTransactions(userName: String)
}

struct Gateway2Service {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://gateway2test.cybex.io")!
        static let devURL = URL(string: "http://39.98.58.238:8181")!
        static let uatURL = URL(string: "https://gateway2test.cybex.io")!
    }

    static let provider = MoyaProvider<GatewayAPI>(callbackQueue: nil, manager: defaultManager(),
                                                        plugins: [NetworkLoggerPlugin(verbose: true)],
                                                        trackInflights: false)


    static func request(
        target: GatewayAPI,
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
//                    if json["code"].intValue == 200 {
//                        let result = json["data"]

                    successCallback(json)
//                    } else {
//                        errorCallback(CybexError.serviceFriendlyError(code: json["code"].intValue,
//                                                                      desc: json["data"]))
//                    }
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

extension GatewayAPI: TargetType {
    var baseURL: URL {
        return Gateway2Service.Config.currentEnv
    }

    var apiVersion: String {
        return "/v1"
    }

    var path: String {
        switch self {
        case .assetLists:
            return apiVersion + "/assets"
        case let .asset(name: name):
            return apiVersion + "/assets/\(name)"
        case let .validateAddress(assetName: assetName, address: address):
            return apiVersion + "/assets/\(assetName)/address/\(address)/verify"
        case let .topUPAddress(assetName: assetName, userName: userName):
            return apiVersion + "/users/\(userName)/assets/\(assetName)/address"
        case let .transactions(fundType: _, assetName: _, userName: userName, fromId: _):
            return apiVersion + "/users/\(userName)/records"
        case let .assetsOfTransactions(userName: userName):
            return apiVersion + "/users/\(userName)/assets"
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
        case let .transactions(fundType: fundType, assetName: assetName, userName: _, fromId: fromId):
            var p: [String: Any] = ["asset": assetName]

            if fundType != .ALL {
                p["fundType"] = fundType.rawValue.lowercased()
            }
            if let id = fromId {
                p["lastid"] = id
            } 

            return p
        default:
            return [:]
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

    var signer: String {
        let time = Date().timeIntervalSince1970.string()
        guard let userName = UserManager.shared.name.value else {
            return ""
        }

        let token = BitShareCoordinator.sign("\(time)\(userName)")
        let jwt = [time, userName, token]

        return jwt.joined(separator: ".")
    }

    var headers: [String: String]? {
        var commonHeader = ["Content-type": "application/json"]

        switch self {
        case .topUPAddress, .transactions, .assetsOfTransactions:
            commonHeader["authorization"] = "bearer " + signer
            return commonHeader
        default:
            return nil
        }
    }
}

