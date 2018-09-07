//
//  ETOCrowdActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

//MARK: - State
struct ETOCrowdState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data: BehaviorRelay<ETOProjectModel?> = BehaviorRelay(value: nil)
    var userData: BehaviorRelay<ETOUserModel?> = BehaviorRelay(value: nil)
}

//MARK: - Action

struct fetchCurrentTokenCountAction: Action {
    var userModel: ETOUserModel
}
