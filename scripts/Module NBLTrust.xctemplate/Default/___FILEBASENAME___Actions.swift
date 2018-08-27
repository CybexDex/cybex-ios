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

//MARK: - State
struct ___VARIABLE_productName:identifier___State: BaseState {
   var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
