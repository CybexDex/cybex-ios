//
//  Gateway.swift
//  cybexMobile
//
//  Created by DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import SwiftyJSON
import RxSwift
import SwiftyUserDefaults
import cybex_ios_core_cpp


/// 网关查询api
///
/// - login: 必须先登录在调用其他接口
/// - records: 查询冲提现记录 默认 20 条
/// - assetKinds: 查询冲提现币种种类
enum GatewayQueryAPI {
    case login(accountName: String)

    case records(accountName: String, asset: String, fundType: FundType, offset: Int)

    case assetKinds(accountName: String)
}

/// 网关查询 冲提现记录
///
/// - 需要先用私钥签名并且登录
/// - 获取 accesstoken 之后查询使用
/// - 600s 后需要再次登录获取
struct GatewayQueryService {
    enum Config {
        static let productURL = URL(string: "https://gateway-query.cybex.io")!
        static let devURL = URL(string: "https://gateway-query.cybex.io")!

        static let loginExpiration: Double = 600
    }

    static let provider = MoyaProvider<GatewayQueryAPI>(callbackQueue: nil, manager: defaultManager(),
                                                        plugins: [NetworkLoggerPlugin(verbose: true)],
                                                        trackInflights: false)

    static var signer = ""

    static func request(
        target: GatewayQueryAPI,
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
                    if json["code"].intValue == 200 {
                        let result = json["data"]

                        //保存accesstoken
                        if !result["signer"].stringValue.isEmpty {
                            self.signer = result["signer"].stringValue
                        }
                        successCallback(result)
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

extension GatewayQueryAPI: TargetType {
    var baseURL: URL {
        return Defaults.isTestEnv ? GatewayQueryService.Config.devURL : GatewayQueryService.Config.productURL
    }

    var path: String {
        switch self {
        case .login:
            return "/login"
        case let .records(accountName, _, _, _):
            return "/records/\(accountName)"
        case let .assetKinds(accountName):
            return "/account-assets/\(accountName)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }

    var urlParameters: [String: Any] {
        switch self {
        case let .records(_, asset, fundType, offset):
            return ["asset": asset, "fundType": fundType.rawValue, "size": 20, "offset": offset]
        default:
            return [:]
        }
    }

    var parameters: [String: Any] {
        switch self {
        case let .login(accountName):
            let (expiration, signer) = sign(accountName: accountName)

            return ["op": ["accountName": accountName, "expiration": expiration], "signer": signer ]
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
        var commonHeader = ["Content-type": "application/json"]

        switch self {
        case .login:
            return commonHeader
        default:
            commonHeader["authorization"] = "bearer " + GatewayQueryService.signer
            return commonHeader
        }
    }
}

extension GatewayQueryAPI {
    func sign(accountName: String) -> (expiration: Int, signer: String) {
        let expiration = Date().timeIntervalSince1970 + GatewayQueryService.Config.loginExpiration

        let signer = BitShareCoordinator.getRecodeLoginOperation(accountName,
                                                                 asset: "",
                                                                 fundType: "",
                                                                 size: Int32(0),
                                                                 offset: Int32(0),
                                                                 expiration: Int32(expiration))!

        return (Int(expiration), JSON(parseJSON: signer)["signer"].stringValue)
    }
}
