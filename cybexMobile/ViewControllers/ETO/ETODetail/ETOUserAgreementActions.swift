//
//  ETOUserAgreementActions.swift
//  cybexMobile
//
//  Created DKM on 2018/9/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwiftyJSON

//MARK: - State
struct ETOUserAgreementState: BaseState {
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
}

//MARK: - Action
struct ETOUserAgreementFetchedAction: Action {
    var data:JSON
}
