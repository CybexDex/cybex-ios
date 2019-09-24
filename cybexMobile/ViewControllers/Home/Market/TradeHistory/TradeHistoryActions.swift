//
//  TradeHistoryActions.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON
import RxCocoa
import RxSwift

// MARK: - State
struct TradeHistoryState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)

    var data: BehaviorRelay<[TradeHistoryViewModel]> = BehaviorRelay(value: [])
}

struct FetchedFillOrderData: ReSwift.Action {
    let data: [JSON]
    let pair: Pair
}
