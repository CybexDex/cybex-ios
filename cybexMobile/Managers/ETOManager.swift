//
//  ETOManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

struct ETOStateOption: OptionSet {
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
    case loginPage
}

enum ETOJoinButtonState {
    case normal(title: String, style: ETOJoinButtonStyle, action: ETOJoinButtonAction)
    case disable(title: String, style: ETOJoinButtonStyle)
    case notShow

}

extension ETOJoinButtonState: Equatable {
    static func == (lhs: ETOJoinButtonState, rhs: ETOJoinButtonState) -> Bool {
        switch (lhs, rhs) {
        case (.normal(let titlelhs, let stylelhs, let actionlhs), .normal(let titlerhs, let stylerhs, let actionrhs)):
            return titlelhs == titlerhs && stylelhs == stylerhs && actionlhs == actionrhs
        case let (.disable(titlelhs, stylelhs), .disable(titlerhs, stylerhs)):
            return titlelhs == titlerhs && stylelhs == stylerhs
        case (_, _):
            return true
        }
    }
}

class ETOManager {
    static let shared = ETOManager()

    private(set) var state = ETOStateOption.unset

    private init() {

    }

    func changeState(_ state: ETOStateOption) {
        let loginState: ETOStateOption = [.login, .notLogin]
        let kycState: ETOStateOption = [.KYCPassed, .KYCNotPassed]
        let userReserveState: ETOStateOption = [.reserved, .notReserved]
        let projectBookState: ETOStateOption = [.bookable, .notBookable]
        let auditState: ETOStateOption = [.auditPassed, .auditNotPassed, .waitAudit]
        let projectState: ETOStateOption = [.notStarted, .underway, .finished]

        for stateSet in [loginState, kycState, userReserveState, projectBookState, auditState, projectState] {
            if stateSet.contains(state.intersection(stateSet)) {
                self.state.remove(stateSet)
                self.state.insert(state.intersection(stateSet))
            }
        }
    }

    func getClauseState() -> ETOClauseState {
        if state.contains([.login, .KYCPassed, .notReserved, .bookable]) && !state.contains(.finished) {
            return .normal
        } else if state.contains([.login, .KYCPassed, .reserved]) && !state.contains(.finished) {
            return .checkedAndImmutable
        }

        return .notShow
    }

    func getETOJoinButtonState() -> ETOJoinButtonState {
        let clause = getClauseState()
        switch clause {
        case .normal:
            return .normal(title: R.string.localizable.eto_project_reserve_now.key.localized(), style: .normal, action: .inputCode)
        case .checkedAndImmutable:
            if state.contains(.auditPassed) {
                if state.contains(.notStarted) {
                    return .disable(title: R.string.localizable.eto_project_waiting.key.localized(), style: .wait)
                }
                return .normal(title: R.string.localizable.eto_project_join.key.localized(), style: .normal, action: .crowdPage)
            } else if state.contains(.waitAudit) {
                return .disable(title: R.string.localizable.eto_project_verifying.key.localized(), style: .wait)
            } else {
                return .disable(title: R.string.localizable.eto_project_rejected.key.localized(), style: .notPassed)
            }
        case .notShow:
            if state.contains(.notReserved) {
                if !state.contains(.finished) {
                    return .disable(title: R.string.localizable.eto_project_stop_reserve.key.localized(), style: .disable)
                }
            } else if state.contains(.KYCNotPassed) {
                return .normal(title: R.string.localizable.eto_project_kyc.key.localized(), style: .normal, action: .icoapePage)
            } else if state.contains(.notLogin) && !state.contains(.finished) {
                return .normal(title: R.string.localizable.eto_project_login.key.localized(), style: .normal, action: .loginPage)
            }
            return .notShow
        }
    }
}
