//
//  TradeActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct TradeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: TradePropertyState
}

struct TradePropertyState {
}

//MARK: - Action Creator
class TradePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: TradeState, _ store: Store<TradeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: TradeState,
        _ store: Store <TradeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
