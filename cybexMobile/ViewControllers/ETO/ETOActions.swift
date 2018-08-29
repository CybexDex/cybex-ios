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
    var data : BehaviorRelay<[ETOProjectModel]?> = BehaviorRelay(value: nil)
    var banners : BehaviorRelay<[ETOBannerModel]?> = BehaviorRelay(value: nil)
}

//MARK: - Action
struct FetchProjectModelAction : Action {
    var data : [ETOProjectInfo]
}


struct FetchBannerModelAction : Action {
    var data : [ETOBannerModel]
}
