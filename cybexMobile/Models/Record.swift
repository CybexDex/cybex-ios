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

struct Record : HandyJSON {
    
    var accountName : String = ""
    var address : String = ""
    var amount : Int = 0
    var asset : String = ""
    var coinType : String = ""
    var fundType : String = ""
    var state : String = ""
    var updateAt : Date!
    var details: [RecordDetail]?
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.updateAt <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.zzz'Z'")
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
        }
        else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
            if let dateString = value as? String {
                return dateFormatter.date(from: dateString)
            }
            return nil
        }
    }
}


struct TradeRecord : HandyJSON {
    var total : Int = 0
    var size : Int = 0
    var offset : Int = 0
    var records : [Record]?
    
    init() {}
}


struct HandyAsset : HandyJSON {
    var amount : String = ""
    var asset_id : String = ""
    init(){}
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            amount <-- "amount"
    }
}


struct Memo : HandyJSON{
    var from : String = ""
    var message : String = ""
    var to : String = ""
    var nonce : String = ""
}



struct TransferRecord : HandyJSON {
    var fee : HandyAsset?
    var from : String = ""
    var to : String = ""
    var amount : HandyAsset?
    var memo : Memo?
    var block_num : Int = 0
    var vesting_period : String = ""
    var public_key : String = ""
    
    init(){}
    
}

struct TransferRecordViewModel {
    var isSend : Bool = false
    var from : String = ""
    var to : String = ""
    var time : String = ""
    var amount : HandyAsset?
    var memo : String = ""
    var vesting_period : String = ""
    var fee : HandyAsset?
}


struct AccountAssetModel: HandyJSON {
    var count: Int = 0
    var groupInfo: GroupInfo?
}


struct GroupInfo: HandyJSON {
    var asset: String = ""
    var fundType: String = ""
}

struct AccountAssets: HandyJSON{
    var total: Int = 0
    var offset: Int = 0
    var size: Int = 0
    var records: [AccountAssetModel]?
}

