//
//  MarketActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import Moya
import HandyJSON
import RxCocoa

// MARK: - State
struct MarketState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var detailData: BehaviorRelay<[Pair: [Candlesticks: [Bucket]]]?> = BehaviorRelay(value: nil)
}

struct KLineFetched: Action {
    let pair: Pair
    let stick: Candlesticks
    let assets: [Bucket]
}
