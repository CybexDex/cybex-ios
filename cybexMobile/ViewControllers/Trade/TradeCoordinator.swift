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
    func addHomeVC()

    func setupChildVC(_ segue: UIStoryboardSegue)
}

protocol TradeStateManagerProtocol {
    var state: TradeState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TradeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState

}

class TradeCoordinator: TradeRootCoordinator {

    lazy var creator = TradePropertyActionCreate()

    var store = Store<TradeState>(
        reducer: TradeReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )

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
        vc.rechargeShowType = PairRechargeView.show_type.hidden.rawValue
        let coordinator = MarketCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func addHomeVC() {
        //    let width = ModalSize.full
        //    let height = ModalSize.custom(size: 397)
        //    let center = ModalCenterPosition.customOrigin(origin: CGPoint(x: 0, y: 397 * 0.5))
        //    let customType = PresentationType.custom(width: width, height: height, center: center)
        //
        //    let presenter = Presentr(presentationType: customType)
        //    presenter.dismissOnSwipeDirection = .top
        //    presenter.presentationType = .popup

        guard let tradeVC = self.rootVC.topViewController as? TradeViewController else { return }

        guard let vc = R.storyboard.main.homeViewController() else { return }
        vc.VC_TYPE = view_type.businessTitle.rawValue

        guard let homeView = vc.view else { return }
        let coordinator = HomeCoordinator(rootVC: self.rootVC)
        vc.coordinator  = coordinator

        //    tradeVC.customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)

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
        UIView.animate(withDuration: 0.3) {
            tradeVC.view.layoutIfNeeded()
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
            segueinfo.destination.coordinator = ExchangeCoordinator(rootVC: self.rootVC)
            segueinfo.destination.type = .buy
        }

        if let segueinfo = R.segue.tradeViewController.exchangeViewControllerSell(segue: segue) {
            segueinfo.destination.coordinator = ExchangeCoordinator(rootVC: self.rootVC)
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

    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<TradeState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }

}
