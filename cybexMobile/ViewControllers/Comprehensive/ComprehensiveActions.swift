//
//  ComprehensiveActions.swift
//  cybexMobile
//
//  Created DKM on 2018/9/19.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON

//MARK: - State
struct ComprehensiveState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
struct ComprehensiveFetchedAction: Action {
    var data:JSON
}
