//
//  ETOActions.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

//MARK: - State
struct ETOState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var data : BehaviorRelay<[ETOProjectViewModel]?> = BehaviorRelay(value: nil)
    var banners : BehaviorRelay<[ETOBannerModel]?> = BehaviorRelay(value: nil)
    var selectedProjectModel: BehaviorRelay<ETOProjectViewModel?> = BehaviorRelay(value: nil)
    var selectedBannerModel: BehaviorRelay<ETOBannerModel?> = BehaviorRelay(value: nil)
}

//MARK: - Action
struct FetchProjectModelAction: Action {
    var data : [ETOProjectModel]
}

struct FetchBannerModelAction: Action {
    var data : [ETOBannerModel]
}

struct SetSelectedProjectModelAction: Action {
    var data : ETOProjectViewModel
}

struct SetSelectedBannerModelAction: Action {
    var data : ETOBannerModel
}


