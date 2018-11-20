//
//  ExchangeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct ExchangeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: ExchangePropertyState
}

struct ExchangePropertyState {
}
