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
    var adds_banner:String = ""
    var adds_banner__lang_en:String = ""
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
            self.finish_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.zzz'Z'")
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
}

struct ETOTradeHistoryModel: HandyJSON {
    var project_id:Int = 0
    var project_name: String = ""
    var ieo_type: String = "" //receive: 参与ETO send: ETO发币
    var reason:ETOTradeHistoryStatus = .ok
    var create_at:Date!
    var token_count:Double = 0
    var token:String = ""
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.create_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss.zzz'Z'")
    }
}

struct ETOProjectModel:HandyJSON {
    var adds_logo: String = ""
    var adds_logo__lang_en: String = ""
    var adds_keyword: String = ""
    var adds_keyword__lang_en: String = ""
    var adds_advantage: String = ""
    var adds_advantage__lang_en: String = ""
    var adds_website: String = ""
    var adds_website__lang_en: String = ""
    var adds_detail: String = ""
    var adds_detail__lang_en: String = ""
    
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

