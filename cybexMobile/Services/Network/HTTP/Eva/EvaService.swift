//
//  EvaService.swift
//  cybexMobile
//
//  Created by dzm on 2018/12/27.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Moya
import SwiftyUserDefaults
import SwiftyJSON
import Alamofire

enum EvaApi {
    case projectInfo(name: String, tokenName: String)
}

struct EvaService {
    
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://api.evaluape.io")!
        static let devURL = URL(string: "https://api.evaluape.io")!
        static let uatURL = URL(string: "https://api.evaluape.io")!
    }
    
    static let provider = MoyaProvider<EvaApi>(callbackQueue: nil, manager: defaultManager(),
                                               plugins: [NetworkLoggerPlugin(verbose: true)],
                                               trackInflights: false)
    
    static func request(
        target: EvaApi,
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
                                                                      desc: json["msg"]))
                    }
                } catch let serverError {
                    if let json = try? JSON(response.mapJSON()) {
                        if json["code"].intValue != 0 {
                            errorCallback(CybexError.serviceFriendlyError(code: json["code"].intValue,
                                                                          desc: json["msg"]))
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

extension EvaApi : TargetType {
    var baseURL: URL {
        return EvaService.Config.currentEnv
    }
    
    var path: String {
        switch self {
        case .projectInfo:
            return "/project/show"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        if let data = try? JSON(parameters).rawData() {
            return data
        }
        return Data()
    }
    
    var urlParameters: [String: Any] {
        switch self {
        default:
            return [:]
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case let .projectInfo(name, tokenName):
            return ["name" : name, "token_name" : tokenName]
        }
    }
    
    var task: Task {
        switch self {
        default:
            return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
