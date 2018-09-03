//
//  ETOManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct ETOStateOption:OptionSet {
    let rawValue: Int
    
    static let unset = ETOStateOption(rawValue: 1 << 0)

    static let login = ETOStateOption(rawValue: 1 << 1)
    static let notLogin = ETOStateOption(rawValue: 1 << 2)
   
    static let KYCPassed = ETOStateOption(rawValue: 1 << 3)
    static let KYCNotPassed = ETOStateOption(rawValue: 1 << 4)

    static let reserved = ETOStateOption(rawValue: 1 << 5)
    static let notReserved = ETOStateOption(rawValue: 1 << 6)

    static let bookable = ETOStateOption(rawValue: 1 << 7)
    static let notBookable = ETOStateOption(rawValue: 1 << 8)

    static let auditPassed = ETOStateOption(rawValue: 1 << 9)
    static let auditNotPassed = ETOStateOption(rawValue: 1 << 10)
    static let waitAudit = ETOStateOption(rawValue: 1 << 11)

    static let notStarted = ETOStateOption(rawValue: 1 << 12)
    static let underway = ETOStateOption(rawValue: 1 << 13)
    static let finished = ETOStateOption(rawValue: 1 << 14)
}

enum ETOClauseState {
    case normal
    case notShow
    case checkedAndImmutable
}

enum ETOJoinButtonStyle {
    case normal
    case wait
    case notPassed
    case disable
}

enum ETOJoinButtonAction: String {
    case unset
    case inputCode
    case crowdPage
    case icoapePage
    case unlockPage
}

enum ETOJoinButtonState {
    case normal(title: String, style: ETOJoinButtonStyle, action: ETOJoinButtonAction)
    case disable(title: String, style: ETOJoinButtonStyle)
    case notShow
}

class ETOManager {
    static let shared = ETOManager()
    
    private var state = ETOStateOption.unset
    
    private init() {
        
    }
    
    func changeState(_ state:ETOStateOption) {
        let loginState:ETOStateOption = [.login, .notStarted]
        let kycState:ETOStateOption = [.KYCPassed, .KYCNotPassed]
        let userReserveState:ETOStateOption = [.reserved, .notReserved]
        let projectBookState:ETOStateOption = [.bookable, .notBookable]
        let auditState:ETOStateOption = [.auditPassed, .auditNotPassed, .waitAudit]
        let projectState:ETOStateOption = [.notStarted, .underway, .finished]
        
        for stateSet in [loginState, kycState, userReserveState, projectBookState, auditState, projectState] {
            if stateSet.contains(state) {
                self.state.remove(stateSet)
                self.state.insert(state.intersection(stateSet))
            }
        }
    }
    
    func getClauseState() -> ETOClauseState {
        if state.contains([.login, .KYCPassed, .notReserved, .bookable]) && !state.contains(.finished) {
            return .normal
        }
        else if state.contains([.login, .KYCPassed, .reserved, .bookable]) && !state.contains(.finished) {
            return .checkedAndImmutable
        }
        
        return .notShow
    }
    
    func getETOJoinButtonState() -> ETOJoinButtonState {
        let clause = getClauseState()
//MARK: Test
        return .normal(title: "立即众筹", style: .normal, action: .crowdPage)

//        return .disable(title: "停止预约", style: .disable)

        switch clause {
        case .normal:
            return .normal(title: "立即预约", style: .normal, action: .inputCode)
        case .checkedAndImmutable:
            if state.contains(.auditPassed) {
                if state.contains(.notStarted) {
                    return .disable(title: "等待众筹开始", style: .wait)
                }
                return .normal(title: "立即众筹", style: .normal, action: .crowdPage)
            }
            else if state.contains(.waitAudit) {
                return .disable(title: "审核中", style: .wait)
            }
            else {
                return .disable(title: "审核未通过", style: .notPassed)
            }
        case .notShow:
            if state.contains(.notReserved) {
                if !state.contains(.finished) {
                    return .disable(title: "停止预约", style: .disable)
                }
            }
            else if state.contains(.KYCNotPassed) {
                return .normal(title: "进行KYC", style: .normal, action: .icoapePage)
            }
            else if state.contains(.notLogin) && !state.contains(.finished) {
                return .normal(title: "请登录", style: .normal, action: .unlockPage)
            }

            return .notShow

        }
      
    }
}
