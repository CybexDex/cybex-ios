//
//  TradeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Presentr

protocol TradeCoordinatorProtocol {
    func openMyHistory()
    func openMarket(index: Int, currentBaseIndex: Int)

    func removeHomeVC(_ completion:@escaping () -> Void)
    func addHomeVC(_ completion:@escaping () -> Void)

    func setupChildVC(_ segue: UIStoryboardSegue)
}

protocol TradeStateManagerProtocol {
    var state: TradeState { get }
}

class TradeCoordinator: NavCoordinator {
    var store = Store<TradeState>(
        reducer: tradeReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    var orderCoodinator: OrderBookCoordinator!
    var historyCoodinator: TradeHistoryCoordinator!

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.business.tradeViewController()!
        vc.localizedText = R.string.localizable.navTrade.key.localizedContainer()
        let coordinator = TradeCoordinator(rootVC: root)
        vc.coordinator = coordinator
        coordinator.store.dispatch(RouteContextAction(context: context))

        coordinator.orderCoodinator = OrderBookCoordinator(rootVC: root)
        coordinator.historyCoodinator = TradeHistoryCoordinator(rootVC: root)

        return vc
    }

    var homeVCTopConstaint: NSLayoutConstraint!
}

extension TradeCoordinator: TradeCoordinatorProtocol {
    func openMyHistory() {
        guard let tradeVC = self.rootVC.topViewController as? TradeViewController else { return }

        let vc = R.storyboard.business.myHistoryViewController()!
        vc.pair = tradeVC.pair
        let coordinator = MyHistoryCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func openMarket(index: Int, currentBaseIndex: Int) {
        let vc = R.storyboard.main.marketViewController()!
        vc.curIndex = index
        vc.currentBaseIndex = currentBaseIndex
        vc.rechargeShowType = PairRechargeView.ShowType.hidden.rawValue
        let coordinator = MarketCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func addHomeVC(_ completion:@escaping () -> Void) {
        guard let tradeVC = self.rootVC.topViewController as? TradeViewController else { return }

        guard let vc = R.storyboard.main.homeViewController() else { return }
        vc.vcType = ViewType.businessTitle.rawValue

        guard let homeView = vc.view else { return }
        let coordinator = HomeCoordinator(rootVC: self.rootVC)
        vc.coordinator  = coordinator

        tradeVC.addChild(vc)

        tradeVC.view.addSubview(homeView)
        vc.pair = tradeVC.pair

        homeVCTopConstaint = homeView.topToDevice(tradeVC, offset: -tradeVC.view.height, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
        homeView.leftToSuperview(nil, offset: 0, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
        homeView.rightToSuperview(nil, offset: 0, relation: .equal, priority: .required, isActive: true, usingSafeArea: true)
        homeView.height(397)

        vc.didMove(toParent: tradeVC)

        tradeVC.view.layoutIfNeeded()
        homeVCTopConstaint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            tradeVC.view.layoutIfNeeded()
        }) { (isFinished) in
            if isFinished {
                completion()
            }
        }
    }

    func removeHomeVC(_ completion:@escaping () -> Void) {
        guard let tradeVC = self.rootVC.topViewController as? TradeViewController else { return }
        guard let home = tradeVC.children.filter({ $0 is HomeViewController}).first as? HomeViewController else { return }

        home.willMove(toParent: tradeVC)
        home.view.removeFromSuperview()
        home.removeFromParent()

        homeVCTopConstaint.constant = -tradeVC.view.height
        UIView.animate(withDuration: 0.3, animations: {
            tradeVC.view.layoutIfNeeded()
        }) { (isFinished) in
            if isFinished {
                completion()
            }
        }
    }

    func setupChildVC(_ segue: UIStoryboardSegue) {
        if let segueinfo = R.segue.tradeViewController.exchangeViewControllerBuy(segue: segue) {
            let coor = ExchangeCoordinator(rootVC: self.rootVC)
            coor.parent = self
            segueinfo.destination.coordinator = coor
            segueinfo.destination.type = .buy

        }

        if let segueinfo = R.segue.tradeViewController.exchangeViewControllerSell(segue: segue) {
            let coor = ExchangeCoordinator(rootVC: self.rootVC)
            coor.parent = self
            segueinfo.destination.coordinator = coor
            segueinfo.destination.type = .sell
        }

        if let segueinfo = R.segue.tradeViewController.openedOrdersViewController(segue: segue) {
            segueinfo.destination.coordinator = OpenedOrdersCoordinator(rootVC: self.rootVC)
            segueinfo.destination.pageType = .exchange
        }
    }
}

extension TradeCoordinator: TradeStateManagerProtocol {
    var state: TradeState {
        return store.state
    }
}
