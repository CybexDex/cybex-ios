//
//  OrderBookActions.swift
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
struct OrderBookState: BaseState {
    var pageState: BehaviorRelay<PageState> = BehaviorRelay(value: .initial)
    var context: BehaviorRelay<RouteContext?> = BehaviorRelay(value: nil)
    var data: BehaviorRelay<OrderBook?> = BehaviorRelay(value: nil)
    var pair: BehaviorRelay<Pair?> = BehaviorRelay(value: nil)
}

struct OrderBook: Equatable {
    struct Order: Equatable {
        let price: String
        let volume: String

        let volumePercent: Decimal
    }

    let bids: [Order]
    let asks: [Order]
}

struct FetchedOrderBookData: Action {
    let data: OrderBook?
    let pair: Pair
}
