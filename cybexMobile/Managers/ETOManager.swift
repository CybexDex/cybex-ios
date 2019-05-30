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

    static let reserved = ETOStateOption(rawValue: 1 << 3)
    static let notReserved = ETOStateOption(rawValue: 1 << 4)

    static let notStarted = ETOStateOption(rawValue: 1 << 5)
    static let underway = ETOStateOption(rawValue: 1 << 6)
    static let finished = ETOStateOption(rawValue: 1 << 7)
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
        let userReserveState: ETOStateOption = [.reserved, .notReserved]
        let projectState: ETOStateOption = [.notStarted, .underway, .finished]

        for stateSet in [loginState, userReserveState, projectState] {
            if stateSet.contains(state.intersection(stateSet)) {
                self.state.remove(stateSet)
                self.state.insert(state.intersection(stateSet))
            }
        }
    }

    func getClauseState() -> ETOClauseState {
        if state.contains([.login, .notReserved]) && !state.contains(.finished) {
            return .notShow
        } else if state.contains([.login, .reserved]) {
            if state.contains(.notStarted) {
                return .checkedAndImmutable
            }
            else if state.contains(.underway) {
                return .normal
            }
        }
        return .notShow
    }

    func getETOJoinButtonState() -> ETOJoinButtonState {
        let clause = getClauseState()
        switch clause {
        case .normal:
            return .normal(title: R.string.localizable.eto_project_join.key.localized(), style: .normal, action: .crowdPage)
        case .checkedAndImmutable:
            return .disable(title: R.string.localizable.eto_project_waiting.key.localized(), style: .wait)
        case .notShow:
            if state.contains(.notReserved) {
                return .disable(title: R.string.localizable.eto_project_rejected.key.localized(), style: .disable)
            }
            else if state.contains(.notLogin) && !state.contains(.finished) {
                return .normal(title: R.string.localizable.eto_project_login.key.localized(), style: .normal, action: .loginPage)
            }
            return .notShow
        }
    }
}
