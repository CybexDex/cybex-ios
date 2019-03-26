//
//  ETOMGService.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

enum ETOMGAPI {
    case getBanner
    case getProjects(offset:Int, limit:Int)
    case getProjectDetail(id: Int)
    case refreshProject(id:Int)
    case checkUserState(name:String, id:Int)
    case refreshUserState(name:String, pid:Int)
    case getUserTradeList(name:String, page:Int, limit:Int)

    case validCode(name:String, pid:Int, code:String)
}

struct ETOMGService {
    enum Config {
        static let productURL = URL(string: "https://eto.cybex.io/api")!
        static let devURL = URL(string: "https://ieo-apitest.cybex.io/api")!
    }

    static let provider = MoyaProvider<ETOMGAPI>(callbackQueue: nil,
                                                 manager: defaultManager(),
                                                 plugins: [NetworkLoggerPlugin(verbose: true)],
                                                 trackInflights: false)

    static func request(
        target: ETOMGAPI,
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
                        let result = json["result"]
                        successCallback(result)
                    } else {
                        errorCallback(CybexError.serviceFriendlyError(code: json["code"].intValue, desc: json["result"]))
                    }
                } catch let serverError {
                    if let json = try? JSON(response.mapJSON()) {
                        if json["code"].intValue != 0 {
                            errorCallback(CybexError.serviceFriendlyError(code: json["code"].intValue, desc: json["result"]))
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

extension ETOMGAPI: TargetType {
    var baseURL: URL {
        return Defaults.isTestEnv ? ETOMGService.Config.devURL : ETOMGService.Config.productURL
    }

    var path: String {
        switch self {
        case .getBanner:
            return "/cybex/projects/banner"
        case .getProjects:
            return "/cybex/projects"
        case .getProjectDetail:
            return "/cybex/project/detail"
        case .refreshProject:
            return "/cybex/project/current"
        case .checkUserState:
            return "/cybex/user/check_status"
        case .refreshUserState:
            return "/cybex/user/current"
        case .getUserTradeList:
            return "/cybex/trade/list"
        case .validCode:
            return "/cybex/user/create"
        }
    }

    var method: Moya.Method {
        switch self {
        case .validCode:
            return .post
        default:
            return .get
        }
    }

    var urlParameters: [String: Any] {
        switch self {
        case .getBanner:
            return ["client": "mobile"]
        case .getProjectDetail(let id):
            return ["project": id]
        case .getProjects(let offset, let limit):
            return ["limit": limit, "offset": offset]
        case .refreshProject(let id):
            return ["project": id]
        case .checkUserState(let name, let id):
            return ["cybex_name": name, "project": id]
        case .refreshUserState(let name, let id):
            return ["cybex_name": name, "project": id]
        case .getUserTradeList(let name, let page, let limit):
            return ["cybex_name": name, "page": page, "limit": limit]
        default:
            return [:]
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .validCode(let name, let pid, let code):
            return ["user": name, "project": pid, "msg": ["code": code]]
        default:
            return [:]
        }
    }

    var task: Task {
        switch self {
        default:
            return .requestCompositeData(bodyData: sampleData, urlParameters: urlParameters)
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

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
