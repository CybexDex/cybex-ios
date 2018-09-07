//
//  ETODetailActions.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

//MARK: - State
struct ETODetailState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data: BehaviorRelay<ETOProjectModel?> = BehaviorRelay(value: nil)
}

//MARK: - Action

struct SetProjectDetailAction: Action {
    var data: ETOProjectModel
}
