//
//  TransferDetailActions.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct TransferDetailState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: TransferDetailPropertyState
}

struct TransferDetailPropertyState {
}
