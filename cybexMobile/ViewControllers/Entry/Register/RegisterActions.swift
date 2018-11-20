//
//  RegisterActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct RegisterState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: RegisterPropertyState
}

struct RegisterPropertyState {
}
