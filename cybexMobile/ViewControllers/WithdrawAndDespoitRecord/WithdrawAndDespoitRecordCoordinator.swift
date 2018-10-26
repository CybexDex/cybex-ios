//
//  WithdrawAndDespoitRecordCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule

protocol WithdrawAndDespoitRecordCoordinatorProtocol {
    func openRecordDetailUrl(_ url: String)
}

protocol WithdrawAndDespoitRecordStateManagerProtocol {
    var state: WithdrawAndDespoitRecordState { get }

    func switchPageState(_ state: PageState)

    func setupChildrenVC(_ segue: UIStoryboardSegue)

    func childrenFetchData(_ info: String, index: RecordChooseType)
}

class WithdrawAndDespoitRecordCoordinator: AccountRootCoordinator {
    var store = Store(
        reducer: WithdrawAndDespoitRecordReducer,
        state: nil,
        middleware: [TrackingMiddleware]
    )

    var state: WithdrawAndDespoitRecordState {
        return store.state
    }

    override func register() {
        Broadcaster.register(WithdrawAndDespoitRecordCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAndDespoitRecordStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAndDespoitRecordCoordinator: WithdrawAndDespoitRecordCoordinatorProtocol {
    func openRecordDetailUrl(_ url: String) {
        if let vc = R.storyboard.main.cybexWebViewController() {
            vc.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
            vc.vc_type = .recordDetail
            vc.url = URL(string: url)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
}

extension WithdrawAndDespoitRecordCoordinator: WithdrawAndDespoitRecordStateManagerProtocol {
    func switchPageState(_ state: PageState) {
        DispatchQueue.main.async {
            self.store.dispatch(PageStateAction(state: state))
        }
    }

    func setupChildrenVC(_ segue: UIStoryboardSegue) {
        if let segueInfo = R.segue.withdrawAndDespoitRecordViewController.withdrawAndDespoitRecordViewController(segue: segue) {
            segueInfo.destination.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
        }
    }

    func childrenFetchData(_ info: String, index: RecordChooseType) {
        if let vc = self.rootVC.topViewController as? WithdrawAndDespoitRecordViewController {
            for childrenVC in vc.children {
                if let childVC = childrenVC as? RechargeRecodeViewController {
                    childVC.tableView.es.resetNoMoreData()
                    childVC.isNoMoreData = false
                    switch index {
                    case .Asset:
                        if info == R.string.localizable.openedAll.key.localized() {
                            childVC.assetInfo = nil
                        } else {
                            var assetInfo: AssetInfo?
                            for (_, value) in appData.assetInfo {
                                if value.symbol.filterJade == info.filterJade {
                                    assetInfo = value
                                    break
                                }
                            }
                            childVC.assetInfo = assetInfo
                        }
                        break
                    case .FoudType:
                        if info == R.string.localizable.openedAll.key.localized() {
                            childVC.recordType = .ALL
                        } else if info == R.string.localizable.recharge_deposit.key.localized() {
                            childVC.recordType = .DEPOSIT
                        } else if info == R.string.localizable.recharge_withdraw.key.localized() {
                            childVC.recordType = .WITHDRAW
                        }
                        break
                    }
                    childVC.fetchDepositRecords(offset: 0) {}
                }
            }
        }
    }
}
