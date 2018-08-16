//
//  AddAddressActions.swift
//  cybexMobile
//
//  Created DKM on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

//MARK: - State
struct AddAddressState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: AddAddressPropertyState
}

struct AddAddressPropertyState {
    var asset : BehaviorRelay<String> = BehaviorRelay(value: "")
    var address :BehaviorRelay<String> = BehaviorRelay(value: "")
    var note : BehaviorRelay<String> = BehaviorRelay(value: "")
    var memo : BehaviorRelay<String> = BehaviorRelay(value: "")
}

//MARK: - Action Creator
class AddAddressPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: AddAddressState, _ store: Store<AddAddressState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: AddAddressState,
        _ store: Store <AddAddressState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
