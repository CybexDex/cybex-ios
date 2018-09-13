//
//  ETO.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import HandyJSON
import DifferenceKit
import RxSwift
import RxCocoa
import Localize_Swift

struct ETOBannerModel:HandyJSON {
    var id:String = ""
    var adds_banner_mobile:String = ""
    var adds_banner_mobile__lang_en:String = ""
}

enum user_kyc_status: String, HandyJSONEnum {
    case not_start = "not_start"
    case ok = "ok"
}

enum user_status: String, HandyJSONEnum {
    case unstart = "unstart"
    case waiting = "waiting"
    case ok = "ok"
    case reject = "reject"
}

struct ETOUserAuditModel:HandyJSON {
    var kyc_status: user_kyc_status = .not_start //not_start, ok
    var status: user_status = .unstart //unstart: 没有预约 waiting,ok,reject
}

struct ETOShortProjectStatusModel:HandyJSON {
    var current_percent:Double = 0
    var status:ProjectState? //finish pre ok
    var finish_at:Date!
    
    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.finish_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
}

struct ETOUserModel:HandyJSON {
    var current_base_token_count:Double = 0
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
            return R.string.localizable.eto_record_send.key.localized()
        case .send:
            return R.string.localizable.eto_record_receive.key.localized()
        }
    }
}

struct ETOTradeHistoryModel: HandyJSON, Differentiable, Equatable, Hashable {
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
    
    static func == (lhs: ETOTradeHistoryModel, rhs: ETOTradeHistoryModel) -> Bool {
        return lhs.project_id == rhs.project_id && lhs.project_name == rhs.project_name && lhs.ieo_type == rhs.ieo_type && lhs.reason == rhs.reason && lhs.created_at == rhs.created_at && lhs.token_count == rhs.token_count && lhs.token == rhs.token
    }
    
    var hashValue: Int {
        return project_id
    }
}


class ETOProjectModel:HandyJSON {
    var id: Int = 0
    var adds_logo_mobile: String = ""
    var adds_logo_mobile__lang_en: String = ""
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
    var adds_whitepaper: String = ""
    var adds_whitepaper__lang_en: String = ""
    var adds_token_total: String = ""
    var adds_token_total__lang_en: String = ""

    var status: ProjectState? // finish pre ok
    var name: String = ""
    var receive_address: String = ""
    var current_percent:Double = 0
    
    var start_at:Date?
    var end_at:Date?
    var finish_at:Date?
    var offer_at:Date?
    var lock_at:Date?
    var create_at:Date?
    
    var token_name: String = ""
    var base_token_name: String = ""
    var rate:Int = 0 //1 base
    
    var base_max_quota: Double = 0
    var base_accuracy: Int = 0
    var base_min_quota: Double = 0
    
    var project: String = ""
    
    var is_user_in:String = "0" // 0不准预约 1可以预约
    
    var t_total_time: String = ""
    
    func mapping(mapper: HelpingMapper) {
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
        mapper <<<
            self.create_at <-- GemmaDateFormatTransform(formatString: "yyyy-MM-dd HH:mm:ss")
    }
    
    required init() {}
}

enum ProjectState : String ,HandyJSONEnum{
    case finish = "finish"
    case pre = "pre"
    case ok = "ok"
    
    func description() -> String {
        switch self {
        case .finish:
            return R.string.localizable.eto_project_finish.key.localized()
        case .pre:
            return R.string.localizable.eto_project_comming.key.localized()
        case .ok:
            return R.string.localizable.eto_project_progress.key.localized()
        default:
            return ""
        }
    }
}


class ETOProjectViewModel {
    var icon: String = ""
    var icon_en: String = ""
    var name: String = ""
    var key_words: String = ""
    var key_words_en: String = ""
    var status: BehaviorRelay<String> = BehaviorRelay(value: "")
    var current_percent: BehaviorRelay<String> = BehaviorRelay(value: "")
    var progress: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    var projectModel: ETOProjectModel?
//    var timeState: String {
//        if let data = self.projectModel, let state = data.status {
//            if state == .finish {
//                return R.string.localizable.eto_project_time_finish.key.localized()
//            }
//            else if state == .pre {
//                return R.string.localizable.eto_project_time_pre.key.localized()
//            }
//            else {
//                return R.string.localizable.eto_project_time_comming.key.localized()
//            }
//        }
//        return ""
//    }
    
    var time: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var etoDetail: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_name.key.localized() + data.name + "\n"
            result += R.string.localizable.eto_token_name.key.localized() + data.token_name + "\n"
//            var adds_token_total: String = ""
//            var adds_token_total__lang_en: String = ""
            if data.adds_token_total.count != 0 || data.adds_token_total__lang_en.count != 0 {
                if Localize.currentLanguage() == "en" {
                    result += R.string.localizable.eto_total_supply.key.localized() + data.adds_token_total__lang_en + "\n"
                }
                else {
                    result += R.string.localizable.eto_total_supply.key.localized() + data.adds_token_total + "\n"
                }
            }
            
            result += R.string.localizable.eto_start_time.key.localized() + data.start_at!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            result += R.string.localizable.eto_end_time.key.localized() + data.end_at!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            if data.lock_at != nil {
                result += R.string.localizable.eto_start_at.key.localized() + data.lock_at!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            }
            if data.offer_at == nil {
                result += R.string.localizable.eto_token_releasing_time.key.localized() + R.string.localizable.eto_project_immediate.key.localized() + "\n"
            }
            else {
                  result += R.string.localizable.eto_token_releasing_time.key.localized() + data.offer_at!.string(withFormat: "yyyy/MM/dd HH:mm:ss") + "\n"
            }
            result += R.string.localizable.eto_currency.key.localized() + data.base_token_name.filterJade + "\n"

            result += R.string.localizable.eto_exchange_ratio.key.localized() + "1" + data.base_token_name + "=" + "\(data.rate)" + data.token_name
        }
        return result
    }

    var project_website: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_online.key.localized() + data.adds_website + "\n"
            result += R.string.localizable.eto_project_white_Paper.key.localized() + data.adds_whitepaper + "\n"
            if data.adds_detail.count != 0 {
                result += R.string.localizable.eto_project_detail.key.localized() + data.adds_detail
            }
        }
        return result
    }
    
    var project_website_en: String {
        var result: String = ""
        if let data = self.projectModel {
            result += R.string.localizable.eto_project_online.key.localized() + data.adds_website__lang_en + "\n"
            result += R.string.localizable.eto_project_white_Paper.key.localized() + data.adds_whitepaper__lang_en + "\n"
            result += R.string.localizable.eto_project_detail.key.localized() + data.adds_detail__lang_en
        }
        return result
    }
    
    var detail_time: BehaviorRelay<String> = BehaviorRelay(value: "")
    var project_state: BehaviorRelay<ProjectState?> = BehaviorRelay(value:nil)
    init(_ projectModel : ETOProjectModel) {
        self.projectModel = projectModel
        self.name = projectModel.name
        self.key_words = projectModel.adds_keyword
        self.key_words_en = projectModel.adds_keyword__lang_en
        self.status.accept(projectModel.status!.description())
        self.current_percent.accept((projectModel.current_percent * 100).string(digits:2, roundingMode: .down) + "%")
        self.progress.accept(projectModel.current_percent)
        self.icon = projectModel.adds_logo_mobile
        self.icon_en = projectModel.adds_logo_mobile__lang_en
        self.project_state.accept(projectModel.status)
        if let state = projectModel.status {
            if state == .finish {
                if projectModel.t_total_time == "" {
                    self.detail_time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - projectModel.start_at!.timeIntervalSince1970, isHiddenSecond: false))
                    self.time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - projectModel.start_at!.timeIntervalSince1970,isHiddenSecond: false))
                }
                else {
                    self.detail_time.accept(timeHandle(Double(projectModel.t_total_time)!, isHiddenSecond: false))
                    self.time.accept(timeHandle(Double(projectModel.t_total_time)!, isHiddenSecond: false))
                }
            }
            else if state == .pre {
                self.detail_time.accept(timeHandle(projectModel.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                self.time.accept(timeHandle(projectModel.start_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
            }
            else {
                self.detail_time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
                self.time.accept(timeHandle(projectModel.end_at!.timeIntervalSince1970 - Date().timeIntervalSince1970))
            }
        }
    }
}

struct ETOHidden: HandyJSON {
    var isETOEnabled: Bool = false
    var isShareEnabled: Bool = false
}

