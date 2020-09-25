//
//  AccountHistoryService.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/23.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import Moya
import SwiftyJSON
import Alamofire
import SwiftyUserDefaults
import Localize_Swift

enum AccountHistoryAPI {
    case getFillByPairs(userId: String, page: Int, filterInPairs: [Pair], filterOutPairs: [Pair])
    case getTransferRecord(userId:String, page: Int)
}

struct AccountHistoryService {
    enum Config: NetworkHTTPEnv {
        static var productURL = URL(string: "https://live.cybex.io")!
        static let devURL = URL(string: "http://39.105.55.115:8081")!
        static var uatURL = URL(string: "http://47.100.98.113:8081")!
    }

    static let provider = MoyaProvider<AccountHistoryAPI>(callbackQueue: nil, manager: defaultManager(),
                                                          plugins: [AppConfiguration.HTTPLOG],
                                               trackInflights: false)

    static func request(
        target: AccountHistoryAPI,
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

extension AccountHistoryAPI: TargetType {
    var baseURL: URL {
        return AccountHistoryService.Config.currentEnv
    }

    var path: String {
        switch self {
        case .getTransferRecord(userId: _, page: _):
            return "/get_ops_by_transfer_accountspair_mongo"
        case .getFillByPairs:
            return "/get_fill_bypair"
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
        case let .getTransferRecord(userId: uid, page: page): //asset=null&acct_from=1.2.19803&acct_to=1.2.4733&page=0&limit=2
            return ["asset": "null", "acct_from": "or", "acct_to": uid, "page": page, "limit": 20]
        case let .getFillByPairs(userId: uid, page: page, filterInPairs: filterInPairs, filterOutPairs: filterOutPairs):
            let fout = filterOutPairs.count == 0 ? "null" : filterOutPairs.map { "\($0.quote)_\($0.base),\($0.base)_\($0.quote)" }.joined(separator: ",")

            let fin = filterInPairs .count == 0 ? "null" : filterInPairs.map { "\($0.quote)_\($0.base),\($0.base)_\($0.quote)" }.joined(separator: ",")
            return ["account": uid, "start": "null", "end": "null", "filter_in": fin, "filter_out": fout, "limit": 20, "page": page]
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

}

