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

// MARK: - Action Creator
class TransferDetailPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: TransferDetailState, _ store: Store<TransferDetailState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: TransferDetailState,
        _ store: Store <TransferDetailState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
