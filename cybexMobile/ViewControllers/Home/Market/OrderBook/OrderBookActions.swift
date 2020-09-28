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
    var depth: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var lastPrice: BehaviorRelay<(Decimal, UIColor)> = BehaviorRelay(value: (0, UIColor.white))
    var count: Int = 10
    var showTypeIndex: BehaviorRelay<Int> = BehaviorRelay(value: 2)
}

struct ChangeDepthAndCountAction: ReSwift.Action {
    var depth: Int
    var count: Int
}

struct ChangeShowTypeIndexAction: ReSwift.Action {
    var index: Int
}

struct OrderBook: Equatable {
    struct Order: Equatable {
        let price: String
        let volume: Decimal

        let volumePercent: Decimal
    }

    let bids: [Order]
    let asks: [Order]

    var pricePrecision: Int = 0
    var amountPrecision: Int = 0

    init(bids: [Order], asks: [Order]) {
        self.bids = bids
        self.asks = asks
    }
}

struct FetchedOrderBookData: ReSwift.Action {
    let data: OrderBook?
    var pair: Pair
}

struct ChangeOrderBookOfPairAction: ReSwift.Action {
    let pair: Pair
}

struct FetchLastPriceAction: ReSwift.Action {
    var price: Decimal
    var pair: Pair
}

struct ResetTickerAction: ReSwift.Action {}

class OrderBookViewModel {
    var orderbook: BehaviorRelay<OrderBook.Order?> = BehaviorRelay(value: nil)
    var percent: BehaviorRelay<Decimal> = BehaviorRelay(value: 0)
    var isBuy: Bool = false
    init(_ params: (OrderBook.Order, Decimal, Bool)) {
        self.orderbook.accept(params.0)
        self.percent.accept(params.1)
        self.isBuy = params.2
    }
}

