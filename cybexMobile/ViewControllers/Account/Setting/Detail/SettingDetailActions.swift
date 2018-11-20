//
//  SettingDetailActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/2.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct SettingDetailState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: SettingDetailPropertyState
}

struct SettingDetailPropertyState {
}

