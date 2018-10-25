//
//  OpenedOrdersActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

// MARK: - State
struct OpenedOrdersState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: OpenedOrdersPropertyState
}

struct OpenedOrdersPropertyState {
  var data: [Any] = []
}

// MARK: - Action Creator
class OpenedOrdersPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: OpenedOrdersState, _ store: Store<OpenedOrdersState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: OpenedOrdersState,
        _ store: Store <OpenedOrdersState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
