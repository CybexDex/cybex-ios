//
//  EntryActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct EntryState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: EntryPropertyState
}

struct EntryPropertyState {
}
