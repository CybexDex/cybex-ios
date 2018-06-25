//
//  BusinessCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol BusinessCoordinatorProtocol {
}

protocol BusinessStateManagerProtocol {
    var state: BusinessState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<BusinessState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func switchPrice(_ price:String)
}

class BusinessCoordinator: AccountRootCoordinator {
    
    lazy var creator = BusinessPropertyActionCreate()
    
    var store = Store<BusinessState>(
        reducer: BusinessReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension BusinessCoordinator: BusinessCoordinatorProtocol {
    
}

extension BusinessCoordinator: BusinessStateManagerProtocol {
    var state: BusinessState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<BusinessState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
  
  func switchPrice(_ price:String) {
    self.store.dispatch(changePriceAction(price: price))
  }
}
