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

//MARK: - State
struct TradeHistoryState: StateType {
    var isLoading = false
    var page: Int = 1
    var errorMessage:String?
    var property: TradeHistoryPropertyState
}

struct TradeHistoryPropertyState {
  var data:BehaviorRelay<[JSON]> = BehaviorRelay(value: [])
}

struct FetchedFillOrderData:Action {
  let data:[JSON]
}

//MARK: - Action Creator
class TradeHistoryPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: TradeHistoryState, _ store: Store<TradeHistoryState>) -> Action?
    
    public typealias AsyncActionCreator = (
        _ state: TradeHistoryState,
        _ store: Store <TradeHistoryState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
  
  func fetchFillOrders(with pair:Pair, callback:CommonAnyCallback?) -> ActionCreator {
    return { state, store in
      
      let request = GetFillOrderHistoryRequest(pair:pair) { (response) in
        if let callback = callback {
          callback(response)
        }
      }
      
      WebsocketService.shared.send(request: request)
      
      return nil
      
    }
  }
}
