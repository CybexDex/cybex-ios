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
    let state = state ?? ___VARIABLE_productName:identifier___State()
        
    switch action {
    case let action as PageStateAction:
        state.pageState.accept(action.state)
    default:
        break
    }
        
    return state
}


