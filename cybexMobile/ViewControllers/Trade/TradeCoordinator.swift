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
import SwiftyUserDefaults

protocol TradeCoordinatorProtocol {
    func openMyHistory()
    func openMarket(_ pair: Pair)

    func removeHomeVC(_ completion:@escaping () -> Void)
    func addHomeVC(_ completion:@escaping () -> Void)

    func setupChildVC(_ segue: UIStoryboardSegue)
    func showNoticeVC()
    
    func openRuleVC()
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

    let presenter: Presentr = {
        let width = ModalSize.custom(size: 272)
        let height = ModalSize.custom(size: 340)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let customPresenter = Presentr(presentationType: customType)
        customPresenter.roundCorners = true
        return customPresenter
    }()

    var orderCoodinator: OrderBookCoordinator!
    var historyCoodinator: TradeHistoryCoordinator!

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.business.tradeViewController()!
        if let context = context as? TradeContext, context.pageType == .game {
            vc.pair = Pair(base: AssetConfiguration.CybexAsset.ArenaUSDT.id, quote: AssetConfiguration.CybexAsset.ArenaETH.id)
            vc.localizedText = R.string.localizable.navContest.key.localizedContainer()
        } else {
            vc.localizedText = R.string.localizable.navTrade.key.localizedContainer()
        }
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
    func showNoticeVC() {
        let v = CybexScrollNoticeView.show()
        v.didConfirmNotTip.delegate(on: self) { (self, _) in
            Defaults[\.showContestTip] = false
        }
    }

    func openMyHistory() {
        guard let tradeVC = self.rootVC.topViewController as? TradeViewController else { return }

        let vc = R.storyboard.account.orderPageTabViewController()!
        vc.fillOrderOnly = true
        vc.pair = tradeVC.pair
        self.rootVC.pushViewController(vc, animated: true)
    }

    func openMarket(_ pair: Pair) {
        let vc = R.storyboard.main.marketViewController()!
        vc.pair = pair
        vc.rechargeShowType = PairRechargeView.ShowType.hidden.rawValue
        let coordinator = MarketCoordinator(rootVC: self.rootVC)
        vc.coordinator = coordinator
        self.rootVC.pushViewController(vc, animated: true)
    }

    func addHomeVC(_ completion:@escaping () -> Void) {
        guard let tradeVC = self.rootVC.topViewController as? TradeViewController, let context = tradeVC.context else { return }

        guard let vc = R.storyboard.main.homeViewController() else { return }
        vc.vcType = context.pageType == .normal ? ViewType.businessTitle.rawValue : ViewType.gameTradeTitle.rawValue

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
    
    func openRuleVC() {
        guard let _ = self.rootVC.topViewController as? TradeViewController else { return }
        guard let ruleVC = R.storyboard.business.tradeContestViewController() else {return}
        self.rootVC.pushViewController(ruleVC, animated: true)
    }
}

extension TradeCoordinator: TradeStateManagerProtocol {
    var state: TradeState {
        return store.state
    }
}
