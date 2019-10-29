//
//  Record.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

extension String {
    func desccription() -> String {
        switch self {
        case "new":
            return R.string.localizable.recode_state_new.key.localized()
        case "pending":
            return R.string.localizable.recode_state_noensure.key.localized()
        case "failed":
            return R.string.localizable.recode_state_fail.key.localized()
        case "done":
            return R.string.localizable.recode_state_success.key.localized()
        default:
            return R.string.localizable.recode_state_upping.key.localized()
        }
    }
}

struct Record: HandyJSON {
    var address: String = ""
    var amount: Int = 0
    var asset: String = ""
    var fundType: String = ""
    var state: String = ""
    var updateAt: Date!
    var details: [RecordDetail]?

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.updateAt <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    }

    init() {}
}

struct RecordDetail: HandyJSON {
    var id: String = ""
    var state: String = ""
    var hash: String = ""
}

open class GemmaDateFormatTransform: DateFormatterTransform {

    public init(formatString: String) {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = formatString

        super.init(dateFormatter: formatter)
    }

    override open func transformFromJSON(_ value: Any?) -> Date? {
        if let dateString = value as? String, let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
            if let dateString = value as? String {
                return dateFormatter.date(from: dateString)
            }
            return nil
        }
    }
}

struct TradeRecord: HandyJSON {
    var total: Int = 0
    var size: Int = 0
    var offset: Int = 0
    var records: [Record]?

    init() {}
}

struct HandyAsset: HandyJSON {
    var amount: String = ""
    var assetId: String = ""
    init() {}
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            amount <-- "amount"
        mapper <<< self.assetId <-- "asset_id"
    }
}

struct Memo: HandyJSON {
    var from: String = ""
    var message: String = ""
    var to: String = ""
    var nonce: String = ""
}

struct TransferRecord: HandyJSON {
    var fee: HandyAsset?
    var from: String = ""
    var to: String = ""
    var amount: HandyAsset?
    var memo: Memo?
    var blockNum: Int = 0

    var extensions: [Any] = []

    init() {}

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<< self.blockNum <-- "block_num"
    }

    var vestingPeriod: Int {
        if extensions.count > 0, let vestingDatas = extensions[0] as? [Any], let vestingData = vestingDatas[1] as? [String: Any], let period = vestingData["vesting_period"] as? Int {
            return period
        }

        return 0
    }

    var publicKey: String {
        if extensions.count > 1,let vestingDatas = extensions[0] as? [Any], let vestingData = vestingDatas[1] as? [String: Any], let pubkey = vestingData["public_key"] as? String {
            return pubkey
        }

        return ""
    }
}

struct TransferRecordViewModel {
    var isSend: Bool = false
    var name: String = ""
    var time: String = ""
    var amount: String = "--" // +1987.000 USDT
    var memo: String = ""
    var vestingPeriod: String = ""
    var fee: HandyAsset?
    var outside: Bool = false
}

struct AccountAssetModel: HandyJSON {
    var count: Int = 0
    var groupInfo: GroupInfo?
}

struct GroupInfo: HandyJSON {
    var asset: String = ""
    var fundType: String = ""
}

struct AccountAssets: HandyJSON {
    var total: Int = 0
    var offset: Int = 0
    var size: Int = 0
    var records: [AccountAssetModel]?
}
