//
//  YourPortfolioActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct YourPortfolioState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: YourPortfolioPropertyState
}

struct YourPortfolioPropertyState {
}

//MARK: - Action Creator
class YourPortfolioPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: YourPortfolioState, _ store: Store<YourPortfolioState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: YourPortfolioState,
        _ store: Store <YourPortfolioState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
