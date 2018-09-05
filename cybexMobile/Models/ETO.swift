//
//  ETO.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON

struct ETOBannerModel:HandyJSON {
    var id:String = ""
    var adds_banner_mobil:String = ""
    var adds_banner_mobil__lang_en:String = ""
}

struct ETOUserAuditModel:HandyJSON {
    var kyc_result: String = "" //not_start, ok
    var status: String = "" //unstart: 没有预约 waiting,ok,reject
}

struct ETOShortProjectStatusModel:HandyJSON {
    var current_percent:Int = 0
    var status:String = "" //finish pre ok
    var finish_at:Date!
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.finish_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
}

struct ETOUserModel:HandyJSON {
    var current_base_token_count:Int = 0
}

enum ETOTradeHistoryStatus:String, HandyJSONEnum {
    case ok = ""
    
    case projectNotExist = "1"
    case userNotInWhiteList = "2"
    case userFallShort = "3"
    case notInCrowding = "4"
    case projectControlClosed = "5"
    case currencyError = "6"
    case crowdLimit = "7"
    case userCrowdLimit = "8"
    case notMatchUserCrowdMinimum = "9"
    case projectLimitLessThanUserMinimum = "10"
    case userResidualLessThanUserMinimum = "11"
    case portionMoreThanProjectTotalLimit = "12"
    case portionMoreThanUserLimit = "13"
    case moreThanAccuracy = "14"
    case transferWithLockup = "15"
    case fail = "101"
    
    func showTitle() -> String {
        if let reason = self.rawValue.int {
            switch reason {
            case 1...11, 15:
                return R.string.localizable.eto_invalid_sub.key.localized()
            case 12...14:
                return R.string.localizable.eto_invalid_partly_sub.key.localized()
            case 16:
                return R.string.localizable.eto_refund.key.localized()
            default:
                return R.string.localizable.eto_receive_success.key.localized()
            }
        }
        else {
            return R.string.localizable.eto_receive_success.key.localized()
        }
    }
}

enum ETOIEOType:String, HandyJSONEnum {
    case receive
    case send
    
    func showTitle() -> String {
        switch self {
        case .receive:
            return R.string.localizable.eto_record_receive.key.localized()
        case .send:
            return R.string.localizable.eto_record_send.key.localized()
        }
    }
}

struct ETOTradeHistoryModel: HandyJSON {
    var project_id:Int = 0
    var project_name: String = ""
    var ieo_type: ETOIEOType = .receive //receive: 参与ETO send: 到账成功
    var reason:ETOTradeHistoryStatus = .ok
    var created_at:Date!
    var token_count:String = ""
    var token:String = ""
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.created_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
}

struct ETOProjectModel:HandyJSON {
    var adds_logo_mobil: String = ""
    var adds_logo_mobil__lang_en: String = ""
    var adds_keyword: String = ""
    var adds_keyword__lang_en: String = ""
    var adds_advantage: String = ""
    var adds_advantage__lang_en: String = ""
    var adds_website: String = ""
    var adds_website__lang_en: String = ""
    var adds_detail: String = ""
    var adds_detail__lang_en: String = ""
    var adds_share_mobil: String = ""
    var adds_share_mobil__lang_en: String = ""
    var adds_buy_desc: String = ""
    var adds_buy_desc__lang_en: String = ""
    var adds_whitelist: String = ""
    var adds_whitelist__lang_en: String = ""

    var status: String = "" // finish pre ok
    var name: String = ""
    var receive_address: String = ""
    var current_percent:Double = 0
    
    var start_at:Date?
    var end_at:Date?
    var finish_at:Date?
    var offer_at:Date?
    var lock_at:Date?
    
    var token_name: String = ""
    var base_token_name: String = ""
    var rate:Int = 0 //1 base
    
    var base_max_quota: Int = 0
    var base_accuracy: Int = 0
    var base_min_quota: Int = 0
    
    var is_user_in:String = "0" // 0不准预约 1可以预约
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.start_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.end_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.finish_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.offer_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
        mapper <<<
            self.lock_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }

}
