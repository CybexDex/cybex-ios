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

enum GatewayAPI {
    case login
    case records
}

extension GatewayAPI: TargetType {
    var baseURL: URL {
        return URL(string: AppConfiguration.RecodeBaseURLString)!
    }

    var path: String {
        switch self {
        case .login:
            return "login"
        case.records:
            return "records/cybex-test"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var paragrames: [String: Any] {
        return [:]
    }

    var sampleData: Data {
        guard let data = try? JSON(paragrames).rawData() else {
            return Data()
        }
        return data
    }

    var task: Task {
        return .requestPlain
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json", "Authon": ""]
    }
}

struct GatewayService {

    func test() {
        let provider = MoyaProvider<GatewayAPI>(callbackQueue: nil, manager: defaultManager(), plugins: [NetworkLoggerPlugin(verbose: true)], trackInflights: true)
        provider.request(.login, callbackQueue: nil, progress: nil) { result in
            switch result {
            case let .success(response):
                do {
                    let response = try response.filterSuccessfulStatusCodes()
                    let json = try JSON(response.mapJSON())
                    if json["code"].intValue == 0 {
                        _ = json["result"]

                    } else {
                    }
                } catch {
                    if let json = try? JSON(response.mapJSON()) {
                        if json["code"].intValue != 0 {
                        } else {
                        }
                    }
                }
            case .failure:break
            }
        }
    }
}
