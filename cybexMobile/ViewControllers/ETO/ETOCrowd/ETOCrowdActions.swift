//
//  ETOCrowdActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

enum ETOValidStatus: Int {
    case notValid = -1
    case ok = 0

    case notEnough
    case moreThanLimit
    case notAvaliableLimit
    case lessThanLeastLimit
    case precisionError
    case feeNotEnough

    func desc() -> String {
        switch self {
        case .ok, .notValid:
            return ""
        case .feeNotEnough:
            return ETOValidStatus.notEnough.desc()
        default:
            return R.string.localizable.eto_submit_check_error_1.key.replacingOccurrences(of: "1", with: "\(self.rawValue)").localized()
        }
    }
}

// MARK: - State
struct ETOCrowdState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data: BehaviorRelay<ETOProjectModel?> = BehaviorRelay(value: nil)
    var userData: BehaviorRelay<ETOUserModel?> = BehaviorRelay(value: nil)
    var fee: BehaviorRelay<Fee?> = BehaviorRelay(value: nil)
    var validStatus: BehaviorRelay<ETOValidStatus> = BehaviorRelay(value: .notValid)
}

// MARK: - Action

struct FetchCurrentTokenCountAction: Action {
    var userModel: ETOUserModel
}

struct ChangeETOValidStatusAction: Action {
    var status: ETOValidStatus
}
