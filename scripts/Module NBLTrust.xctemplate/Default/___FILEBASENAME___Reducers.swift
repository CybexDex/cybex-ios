//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import ReSwift

func ___VARIABLE_productName:identifier___Reducer(action:Action, state:___VARIABLE_productName:identifier___State?) -> ___VARIABLE_productName:identifier___State {
    return ___VARIABLE_productName:identifier___State(isLoading: loadingReducer(state?.isLoading, action: action), page: pageReducer(state?.page, action: action), errorMessage: errorMessageReducer(state?.errorMessage, action: action), property: ___VARIABLE_productName:identifier___PropertyReducer(state?.property, action: action), callback:state?.callback ?? ___VARIABLE_productName:identifier___CallbackState())
}

func ___VARIABLE_productName:identifier___PropertyReducer(_ state: ___VARIABLE_productName:identifier___PropertyState?, action: Action) -> ___VARIABLE_productName:identifier___PropertyState {
    var state = state ?? ___VARIABLE_productName:identifier___PropertyState()
    
    switch action {
    default:
        break
    }
    
    return state
}



