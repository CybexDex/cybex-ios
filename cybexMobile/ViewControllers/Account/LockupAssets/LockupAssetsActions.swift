//
//  LockupAssetsActions.swift
//  cybexMobile
//
//  Created DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct LockupAssetsState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: LockupAssetsPropertyState
}

struct LockupAssetsPropertyState {
}

//MARK: - Action Creator
class LockupAssetsPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: LockupAssetsState, _ store: Store<LockupAssetsState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: LockupAssetsState,
        _ store: Store <LockupAssetsState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
