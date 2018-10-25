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

// MARK: - Action Creator
class MyHistoryPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: MyHistoryState, _ store: Store<MyHistoryState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: MyHistoryState,
        _ store: Store <MyHistoryState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
