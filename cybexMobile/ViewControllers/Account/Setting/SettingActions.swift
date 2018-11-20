//
//  SettingActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya

// MARK: - State
struct SettingState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: SettingPropertyState
}

struct SettingPropertyState {

}

