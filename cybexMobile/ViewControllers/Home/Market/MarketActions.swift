//
//  MarketActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya

//MARK: - State
struct MarketState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: MarketPropertyState
}

struct MarketPropertyState {
}

//MARK: - Action Creator
class MarketPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: MarketState, _ store: Store<MarketState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: MarketState,
        _ store: Store <MarketState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
