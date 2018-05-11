//
//  HomeActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya

//MARK: - State
struct HomeState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: HomePropertyState
}

struct HomePropertyState {
 
}

//MARK: - Action



//MARK: - Action Creator
class HomePropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: HomeState, _ store: Store<HomeState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: HomeState,
        _ store: Store <HomeState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
