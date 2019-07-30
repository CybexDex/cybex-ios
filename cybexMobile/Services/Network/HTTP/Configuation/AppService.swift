//
//  AppService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/7.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire
import SwiftyUserDefaults
import Localize_Swift

enum AppAPI {
    case nodesURL
    case setting  // 是否显示ETO Share
    case checkVersionUpdate
    case checkAppStoreVersionUpdate
    case explorerURL

    case assetWhiteList
    case stickTopMarketPair
    case marketlist(base: String)
    case precisionSetting // 深度图精度

    case withdrawList
    case topUpList
    case withdrawAnnounce(assetId: String)
    case topUpAnnounce(assetId: String)

    //首页运营页面
    case hotpair
    case homebanner
    case announce
    case items

    case outerPrice
    case evaluapeSetting
}

struct AppService {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://app.cybex.io")!
        static let devURL = URL(string: "http://47.91.242.71:3039")!
        static var uatURL = URL(string: "http://47.100.98.113:3039")!
    }

    static let provider = MoyaProvider<AppAPI>(callbackQueue: nil, manager: defaultManager(),
                                                        plugins: [NetworkLoggerPlugin(verbose: true)],
                                                        trackInflights: false)

    static func request(
        target: AppAPI,
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
                        if let data = json.dictionaryObject?["data"] {
                            successCallback(JSON(data))
                        } else {
                            successCallback(json)
                        }
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

extension AppAPI: TargetType {
    var baseURL: URL {
        return AppService.Config.currentEnv
    }

    var path: String {
        switch self {
        case .nodesURL:
            return "/json/nodes_config.json"
        case .setting:
            return "/json/settings.json"
        case .checkVersionUpdate:
            return "/iOS_update.json"
        case .checkAppStoreVersionUpdate:
            return "/iOS_store_update.json"
        case .hotpair:
            return "/v1/api/hotpair"
        case .announce:
            return "/v1/api/announce"
        case .homebanner:
            return "/v1/api/banners"
        case .items:
            return "/v1/api/app_sublinks"
        case .outerPrice:
            return "/price"
        case .marketlist:
            return "/market_list"
        case .assetWhiteList:
            return "/json/assets.json"
        case .withdrawList:
            return "/json/withdraw.json"
        case .topUpList:
            return "/json/deposit.json"
        case .stickTopMarketPair:
            return "/json/marketlists.json"
        case .explorerURL:
            return "/json/blockexplorer.json"
        case let .withdrawAnnounce(assetId):
            return "/json/withdraw/\(assetId).json"
        case let .topUpAnnounce(assetId):
            return "/json/deposit/\(assetId).json"
        case .precisionSetting:
            return "/json/pairs.json"
        case .evaluapeSetting:
            return "/json/evaluape.json"
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
        case .announce:
            return ["lang": lang]
        case .homebanner:
            return ["lang": lang]
        case .items:
            return ["lang": lang, "env": env]
        case let .marketlist(base):
            return ["base": base]
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
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
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

    //Extra
    var lang: String {
        return (Localize.currentLanguage() == "en" ? "en" : "zh")
    }

    var env: String { //是否是企业版 AppStore版本
        return AppConfiguration.shared.isAppStoreVersion() ? "" : "pro"
    }
}
