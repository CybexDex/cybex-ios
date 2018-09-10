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
    var data: BehaviorRelay<ETOProjectViewModel?> = BehaviorRelay(value: nil)
    var userState: BehaviorRelay<ETOUserAuditModel?> = BehaviorRelay(value: nil)
    var refreshData: BehaviorRelay<ETOProjectViewModel?> = BehaviorRelay(value: nil)

}

//MARK: - Action

struct SetProjectDetailAction: Action {
    var data: ETOProjectModel
}

struct FetchUserStateAction: Action {
    var data: ETOUserAuditModel
}

struct RefrehProjectModelAction: Action {
    var data: ETOShortProjectStatusModel
}
