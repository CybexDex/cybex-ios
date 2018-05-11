//
//  FAQActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya

//MARK: - State
struct FAQState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: FAQPropertyState
}

struct FAQPropertyState {
    
}

//MARK: - Action Creator
class FAQPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: FAQState, _ store: Store<FAQState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: FAQState,
        _ store: Store <FAQState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
