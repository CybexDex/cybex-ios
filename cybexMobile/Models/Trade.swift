//
//  Trade.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON
import SwiftyJSON

class Fee: HandyJSON {
    var assetId: String = ""
    var amount: String = ""
    var success: Bool = false

    required init() {

    }
    func mapping(mapper: HelpingMapper) {
        mapper <<< assetId    <-- "asset_id"
        mapper <<< amount      <-- ("amount", ToStringTransform())
        mapper <<< success     <-- "success"
    }
}

class Current: HandyJSON {
    var headBlockId: String = ""
    var lastIrreversibleBlockNum: String = ""
    required init() {

    }
    func mapping(mapper: HelpingMapper) {
        mapper <<< headBlockId               <-- "head_block_id"
        mapper <<< lastIrreversibleBlockNum <-- ("last_irreversible_block_num", ToStringTransform())
    }
}

struct Trade: HandyJSON {
    var id: String = ""
    var enable: Bool = true
    var enMsg: String = ""
    var cnMsg: String = ""
    var enInfo: String = ""
    var cnInfo: String = ""
    var amount: String = "0"
    var projectName: String = ""
}

struct TradeMsg {
    var enMsg: String = ""
    var cnMsg: String = ""
}

struct RechargeWorldInfo: HandyJSON {
    var projectNameCn: String = ""
    var projectAddressCn: String = ""
    var projectLinkCn: String = ""
    var projectNameEn: String = ""
    var projectAddressEn: String = ""
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

struct RechageWordVMData {
    var projectName: String = ""
    var projectAddress: String = ""
    var projectLink: String = ""
    var messageInfo: String = ""
}
