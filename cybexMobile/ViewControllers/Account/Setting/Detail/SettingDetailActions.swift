//
//  SettingDetailActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/2.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

// MARK: - State
struct SettingDetailState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)

    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
}
