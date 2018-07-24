//
//  TransferListActions.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct TransferListState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: TransferListPropertyState
}

struct TransferListPropertyState {
}

//MARK: - Action Creator
class TransferListPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: TransferListState, _ store: Store<TransferListState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: TransferListState,
        _ store: Store <TransferListState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
