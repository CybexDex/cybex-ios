//
//  ChooseActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct ChooseState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: ChoosePropertyState
}

struct ChoosePropertyState {
}

//MARK: - Action Creator
class ChoosePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: ChooseState, _ store: Store<ChooseState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: ChooseState,
        _ store: Store <ChooseState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
