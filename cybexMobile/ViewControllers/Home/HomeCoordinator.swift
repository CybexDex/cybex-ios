//
//  HomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol HomeCoordinatorProtocol {
  func openMarket(index:Int, currentBaseIndex: Int)
}

protocol HomeStateManagerProtocol {
    var state: HomeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<HomeState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
}

class HomeCoordinator: HomeRootCoordinator {
    lazy var creator = HomePropertyActionCreate()
    
    var store = Store<HomeState>(
        reducer: HomeReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
    
    var state: HomeState {
        return store.state
    }
}

extension HomeCoordinator: HomeCoordinatorProtocol {
  func openMarket(index:Int, currentBaseIndex:Int) {
    let vc = R.storyboard.main.marketViewController()!
    vc.curIndex = index
    vc.currentBaseIndex = currentBaseIndex
    let coordinator = MarketCoordinator(rootVC: self.rootVC)
    vc.coordinator = coordinator
    self.rootVC.pushViewController(vc, animated: true)
  }
}

extension HomeCoordinator: HomeStateManagerProtocol {
  func subscribe<SelectedState, S: StoreSubscriber>(
      _ subscriber: S, transform: ((Subscription<HomeState>) -> Subscription<SelectedState>)?
      ) where S.StoreSubscriberStateType == SelectedState {
      store.subscribe(subscriber, transform: transform)
  }
}
