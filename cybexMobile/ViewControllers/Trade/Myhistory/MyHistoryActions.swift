//
//  MyHistoryActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct MyHistoryState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: MyHistoryPropertyState
}

struct MyHistoryPropertyState {
}
