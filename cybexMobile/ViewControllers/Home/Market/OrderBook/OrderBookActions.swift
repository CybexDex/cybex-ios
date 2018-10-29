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
struct OrderBookState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage: String?
    var property: OrderBookPropertyState
}

struct OrderBookPropertyState {
    var data: BehaviorRelay<OrderBook?> = BehaviorRelay(value: nil)
    var pair: BehaviorRelay<Pair?> = BehaviorRelay(value: nil)
}

struct OrderBook: Equatable {
    struct Order: Equatable {
        let price: String
        let volume: String
        
        let volumePercent: Double
    }
    
    let bids: [Order]
    let asks: [Order]
}

struct FetchedLimitData: Action {
    let data: [LimitOrder]
    let pair: Pair
}

// MARK: - Action Creator
class OrderBookPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: OrderBookState, _ store: Store<OrderBookState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: OrderBookState,
        _ store: Store <OrderBookState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
    
    func fetchLimitOrders(with pair: Pair, callback: CommonAnyCallback?) -> ActionCreator {
        return { state, store in
            
            let request = GetLimitOrdersRequest(pair: pair) { response in
                if let callback = callback {
                    callback(response)
                }
            }
            
            CybexWebSocketService.shared.send(request: request)
            
            return nil
            
        }
    }
}
