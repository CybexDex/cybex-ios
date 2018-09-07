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
    case getBanner()
    case getProjects(offset:Int, limit:Int)
    case getProjectDetail(id: Int)
    case refreshProject(id:Int)
    case checkUserState(name:String, id:Int)
    case refreshUserState(name:String, pid:Int)
    case getUserTradeList(name:String, page:Int, limit:Int)
    
    case validCode(name:String, pid:Int, code:String)
}

func defaultManager() -> Alamofire.SessionManager {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    configuration.timeoutIntervalForRequest = 15
    
    let manager = Alamofire.SessionManager(configuration: configuration)
    manager.startRequestsImmediately = false
    return manager
}

struct ETOMGService {
    static let provider = MoyaProvider<ETOMGAPI>(callbackQueue: nil, manager: defaultManager(), plugins: [NetworkLoggerPlugin(verbose: true)], trackInflights: false)
    
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
                    }
                    else {
                        errorCallback(CybexError.ServiceFriendlyError(code: json["code"].intValue, desc: json["result"].stringValue))
                    }
                }
                catch let serverError {
                    failureCallback(CybexError.ServiceHTTPError(desc: serverError.localizedDescription))
                }
            case let .failure(error):
                failureCallback(CybexError.ServiceHTTPError(desc: error.localizedDescription))
            }
        }
    }
}

extension ETOMGAPI : TargetType {
    var baseURL: URL {
        if Defaults[.environment] == "test" {
            return AppConfiguration.ETO_MG_BASE_TEST_URLString
        }
        return AppConfiguration.ETO_MG_BASE_URLString
    }
    
    var path: String {
        switch self {
        case .getBanner():
            return "/cybex/projects/banner"
        case .getProjects(_, _):
            return "/cybex/projects"
        case .getProjectDetail(_):
            return "/cybex/project/detail"
        case .refreshProject(_):
            return "/cybex/project/current"
        case .checkUserState(_, _):
            return "/cybex/user/check_status"
        case .refreshUserState(_, _):
            return "/cybex/user/current"
        case .getUserTradeList(_, _, _):
            return "/cybex/trade/list"
        case .validCode(_,_,_):
            return "/cybex/user/create"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .validCode(_,_,_):
            return .post
        default:
            return .get
        }
    }
    
    var urlParameters: [String:Any] {
        switch self {
        case .getBanner():
            return ["client":"mobile"]
        case .getProjectDetail(let id):
            return ["project": id]
        case .getProjects(let offset, let limit):
            return ["limit":limit, "offset": offset]
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
            return ["user":name, "project":pid, "msg": ["code": code]]
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
        return try! JSON(parameters).rawData()
    }
    
    
    var headers: [String : String]? {
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
