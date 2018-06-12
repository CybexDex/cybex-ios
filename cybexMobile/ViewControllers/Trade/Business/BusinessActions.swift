//
//  BusinessActions.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct BusinessState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: BusinessPropertyState
}

struct BusinessPropertyState {
}

//MARK: - Action Creator
class BusinessPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: BusinessState, _ store: Store<BusinessState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: BusinessState,
        _ store: Store <BusinessState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
