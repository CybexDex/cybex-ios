//
//  GatewayResponseModel.swift
//  cybexMobile
//
//  Created by koofrank on 2019/3/28.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct GatewayAssetResponseModel: HandyJSON {
    var name: String = ""
    var projectname: String = ""
    var cybname: String = ""
    var cybid: String = ""

    var gatewayAccount: String = ""
    var withdrawPrefix: String = ""
    var depositSwitch: Bool = false
    var withdrawSwitch: Bool = false
    var minDeposit: String = ""
    var minWithdraw: String = ""
    var withdrawFee: String = ""
    var depositFee: String = ""
    var precision: String = ""
    var hashLink: String = ""
    var useMemo: Bool = false
    var info: [String: Any] = [:]
}

enum GateWayTransactionStatus: String, HandyJSONEnum {
    case pending = "PENDING"
    case done = "DONE"
    case failed = "FAILED"
}

struct GatewayTransactionResponseModel: HandyJSON {
    var id: Int = 0
    var outAddr: String = ""
    var confirms: String = ""
    var asset: String = ""
    var totalAmount: String = ""
    var amount: String = ""
    var status: GateWayTransactionStatus = .pending
    var fee: String = ""
    var updatedAt: Date!
    var link: String = ""
    var outHash: String = ""
    var type: String = ""

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.updatedAt <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss'Z'")
    }
}

class CombineTextTransform: TransformType {
    public typealias Object = String
    public typealias JSON = [[String: String]]

    public init() {}

    open func transformFromJSON(_ value: Any?) -> String? {
        if let origin = value as? [[String: String]] {
            return origin.compactMap({ (dict) -> String in
                return dict["text"] ?? ""
            }).joined(separator: "\n")
        }

        return nil
    }

    open func transformToJSON(_ value: String?) -> [[String: String]]? {
        if let val = value {
            return val.components(separatedBy: "\n").compactMap({ (str) -> [String: String] in
                return ["text": str]
            })
        }
        return nil
    }
}

class ExportArrayValueTransform: TransformType {
    public typealias Object = String
    public typealias JSON = [[String: String]]

    var index: Int
    var key: String

    public init(_ index: Int, key: String) {
        self.index = index
        self.key = key
    }

    open func transformFromJSON(_ value: Any?) -> String? {
        if let origin = value as? [[String: String]] {
            if index < origin.count {
                return origin[index][key]
            }
        }

        return nil
    }

    open func transformToJSON(_ value: String?) -> [[String: String]]? {
        return nil
    }
}
