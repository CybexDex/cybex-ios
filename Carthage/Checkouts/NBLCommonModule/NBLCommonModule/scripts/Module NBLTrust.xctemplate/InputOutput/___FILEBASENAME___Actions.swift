//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON
import HandyJSON

struct ___VARIABLE_productName:identifier___Context: RouteContext, HandyJSON {
    init() {}
    
}

//MARK: - State
struct ___VARIABLE_productName:identifier___State: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
struct ___VARIABLE_productName:identifier___FetchedAction: Action {
    var data:JSON
}
