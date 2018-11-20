//
//  RechargeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import HandyJSON
import NBLCommonModule

struct RechargeContext: RouteContext, HandyJSON {
    init() {}

    var selectedIndex: RechargeViewController.CellType = .RECHARGE
}

protocol RechargeCoordinatorProtocol {
    func openRechargeDetail(_ trade: Trade)
    func openWithDrawDetail(_ trade: Trade)
    func openRecordList()
}

protocol RechargeStateManagerProtocol {
    var state: RechargeState { get }

    func fetchWithdrawIdsInfo()
    func fetchDepositIdsInfo()
    func sortedEmptyAsset(_ isEmpty: Bool)
    func sortedNameAsset(_ name: String)
}

class RechargeCoordinator: NavCoordinator {
    var store = Store(
        reducer: rechargeReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override func register() {
        Broadcaster.register(RechargeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(RechargeStateManagerProtocol.self, observer: self)

    }

    override class func start(_ root: BaseNavigationController, context: RouteContext? = nil) -> BaseViewController {
        let vc = R.storyboard.account.rechargeViewController()!
        let coordinator = RechargeCoordinator(rootVC: root)
        vc.coordinator = coordinator
        if let con = context as? RechargeContext {
            vc.selectedIndex = con.selectedIndex
        }
        coordinator.store.dispatch(RouteContextAction(context: context))

        return vc
    }

}

extension RechargeCoordinator: RechargeCoordinatorProtocol {
    func openRechargeDetail(_ trade: Trade) {
        let vc = R.storyboard.account.rechargeDetailViewController()!
        let coordinator   = RechargeDetailCoordinator(rootVC: self.rootVC)
        vc.coordinator    = coordinator
        vc.trade          = trade
        vc.isWithdraw     = trade.enable
        self.rootVC.pushViewController(vc, animated: true)
    }

    func openWithDrawDetail(_ trade: Trade) {
        if let withdrawDetailVC = R.storyboard.account.withdrawDetailViewController() {
            let coordinator = WithdrawDetailCoordinator(rootVC: self.rootVC)
            withdrawDetailVC.coordinator = coordinator
            withdrawDetailVC.trade = trade
            self.rootVC.pushViewController(withdrawDetailVC, animated: true)
        }
    }

    func openRecordList() {
        if let recordVC = R.storyboard.comprehensive.withdrawAndDespoitRecordViewController() {
            recordVC.coordinator = WithdrawAndDespoitRecordCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(recordVC, animated: true)
        }
    }
}

extension RechargeCoordinator: RechargeStateManagerProtocol {
    var state: RechargeState {
        return store.state
    }

    func fetchWithdrawIdsInfo() {
        SimpleHTTPService.fetchWithdrawIdsInfo().done { (ids) in
            self.store.dispatch(FecthWithdrawIds(data: ids))
            }.cauterize()
    }
    func fetchDepositIdsInfo() {
        SimpleHTTPService.fetchDesipotInfo().done { (ids) in
            self.store.dispatch(FecthDepositIds(data: ids))
            }.cauterize()
    }
    func sortedEmptyAsset(_ isEmpty: Bool) {
        self.store.dispatch(SortedByEmptyAssetAction(data: isEmpty))
    }
    func sortedNameAsset(_ name: String) {
        self.store.dispatch(SortedByNameAssetAction(data: name))
    }
}
