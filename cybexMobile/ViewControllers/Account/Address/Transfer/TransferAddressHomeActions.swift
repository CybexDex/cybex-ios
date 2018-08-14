//
//  TransferAddressHomeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct TransferAddressHomeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: TransferAddressHomePropertyState
    var callback: TransferAddressHomeCallbackState
}

struct TransferAddressHomePropertyState {
}

struct TransferAddressHomeCallbackState {
}

//MARK: - Action Creator
class TransferAddressHomePropertyActionCreate {
    public typealias ActionCreator = (_ state: TransferAddressHomeState, _ store: Store<TransferAddressHomeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: TransferAddressHomeState,
        _ store: Store <TransferAddressHomeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
