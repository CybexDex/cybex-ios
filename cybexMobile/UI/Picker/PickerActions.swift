//
//  PickerActions.swift
//  cybexMobile
//
//  Created peng zhu on 2018/7/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct PickerState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: PickerPropertyState
}

struct PickerPropertyState {
}

// MARK: - Action Creator
class PickerPropertyActionCreate {
    public typealias ActionCreator = (_ state: PickerState, _ store: Store<PickerState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: PickerState,
        _ store: Store <PickerState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
