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
    var fullName: String = ""
    var confirmationNums: Int = 0
    var name: String = ""
    var id: String = ""
    var gatewayAccount: String = ""
    var withdrawSwith: Bool = false
    var depositSwitch: Bool = false
    var withdrawFee: String = ""
    var minWithdraw: String = ""
    var precision: String = ""
    var info: GatewayAssetInfoResponseModel = GatewayAssetInfoResponseModel()

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< fullName                   <-- "blockchain.name"
        mapper <<< confirmationNums           <-- "blockchain.confirmation"
    }
}

struct GatewayAssetInfoResponseModel: HandyJSON {
    var projectNameCn: String = ""
    var projectNameEn: String = ""

    var projectAddressCn: String = ""
    var projectAddressEn: String = ""

    var projectLinkCn: String = ""
    var projectLinkEn: String = ""

    var enInfo: String = ""
    var cnInfo: String = ""

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< projectNameCn               <-- ("msg_cn", ExportArrayValueTransform(0, key: "value"))
        mapper <<< projectAddressCn               <-- ("msg_cn", ExportArrayValueTransform(1, key: "value"))
        mapper <<< projectLinkCn               <-- ("msg_cn", ExportArrayValueTransform(1, key: "link"))
        mapper <<< projectNameEn               <-- ("msg_en", ExportArrayValueTransform(0, key: "value"))
        mapper <<< projectAddressEn               <-- ("msg_en", ExportArrayValueTransform(1, key: "value"))
        mapper <<< projectLinkEn               <-- ("msg_en", ExportArrayValueTransform(1, key: "link"))
        mapper <<< enInfo               <--  ("notice_en.adds", CombineTextTransform())
        mapper <<< cnInfo               <-- ("notice_cn.adds", CombineTextTransform())
    }
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
    var amount: String = ""
    var status: GateWayTransactionStatus = .pending
    var fee: String = ""
    var updateAt: Date!
    var link: String = ""

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.updateAt <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
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
