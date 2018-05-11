//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import ReSwift

//MARK: - State
struct ___VARIABLE_productName:identifier___State: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: ___VARIABLE_productName:identifier___PropertyState
}

struct ___VARIABLE_productName:identifier___PropertyState {
}

//MARK: - Action Creator
class ___VARIABLE_productName:identifier___PropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: ___VARIABLE_productName:identifier___State, _ store: Store<___VARIABLE_productName:identifier___State>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: ___VARIABLE_productName:identifier___State,
        _ store: Store <___VARIABLE_productName:identifier___State>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
