//
//  MarketCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwifterSwift

protocol MarketCoordinatorProtocol {

}

protocol MarketStateManagerProtocol {
    var state: MarketState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<MarketState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState

    func setupChildViewControllers(_ pair: Pair) -> [BaseViewController]
    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair)
    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair)
}

class MarketCoordinator: HomeRootCoordinator {

    lazy var creator = MarketPropertyActionCreate()

    var store = Store<MarketState>(
        reducer: MarketReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )

    var state: MarketState {
        return store.state
    }
}

extension MarketCoordinator: MarketCoordinatorProtocol {
    func setupChildViewControllers(_ pair: Pair) -> [BaseViewController] {
        let vc = R.storyboard.main.orderBookViewController()!
        let coordinator = OrderBookCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        vc.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

        let vc2 = R.storyboard.main.tradeHistoryViewController()!
        let coordinator2 = TradeHistoryCoordinator(rootVC: self.rootVC)
        vc2.coordinator = coordinator2
        vc2.view.theme_backgroundColor = [#colorLiteral(red: 0.06666666667, green: 0.0862745098, blue: 0.1294117647, alpha: 1).hexString(true), #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9568627451, alpha: 1).hexString(true)]

        refreshChildViewController([vc, vc2], pair: pair)

        return [vc, vc2]
    }

    func refreshChildViewController(_ vcs: [BaseViewController], pair: Pair) {
        for vc in vcs {
            if let vc = vc as? OrderBookViewController {
                vc.pair = pair
            } else if let vc = vc as? TradeHistoryViewController {
                vc.pair = pair
            }
        }
    }
}

extension MarketCoordinator: MarketStateManagerProtocol {

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<MarketState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

    func openTradeViewChontroller(_ isBuy: Bool, pair: Pair) {
        self.rootVC.tabBarController?.selectedIndex = 2
        self.rootVC.popToRootViewController(animated: false)

        SwifterSwift.delay(milliseconds: 100) {
            if let baseNavi = self.rootVC.tabBarController?.viewControllers![2] as? BaseNavigationController, let vc = baseNavi.topViewController as? TradeViewController {
                vc.selectedIndex = isBuy ? 0 : 1
                vc.pair = pair
                vc.titlesView?.selectedIndex = vc.selectedIndex
            }
        }

    }
}
