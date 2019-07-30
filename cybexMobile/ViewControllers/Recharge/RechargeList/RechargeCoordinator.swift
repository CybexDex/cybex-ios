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
import SwiftyJSON

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
        if checkAndfetchFromGateway2(true) {
            return
        }

        AppService.request(target: AppAPI.withdrawList, success: { (json) in
            let list = JSON(json).arrayValue.compactMap({ Trade.deserialize(from: $0.dictionaryObject) })
            self.store.dispatch(FecthWithdrawIds(data: list))
        }, error: { (_) in

        }) { (_) in

        }
    }
    func fetchDepositIdsInfo() {
        if checkAndfetchFromGateway2(false) {
            return
        }
        AppService.request(target: AppAPI.topUpList, success: { (json) in
            let list = JSON(json).arrayValue.compactMap({ Trade.deserialize(from: $0.dictionaryObject) })
            self.store.dispatch(FecthDepositIds(data: list))
        }, error: { (_) in

        }) { (_) in

        }
    }

    func checkAndfetchFromGateway2(_ withdraw: Bool) -> Bool {
        guard let setting = AppConfiguration.shared.enableSetting.value else {
            return false
        }

        let gateway2 = setting.gateWay2
        if gateway2 {
            Gateway2Service.request(target: .assetLists, success: { (json) in
                let list = JSON(json).arrayValue.compactMap({ GatewayAssetResponseModel.deserialize(from: $0.dictionaryObject) }).map({ (newModel) -> Trade in
                    var trade = Trade()
                    trade.name = newModel.name
                    trade.id = newModel.cybid
                    trade.projectName = newModel.projectname
                    trade.enable = withdraw ? newModel.withdrawSwitch : newModel.depositSwitch
                    if let withdrawDic = newModel.info["withdraw"] as? [String: String],
                        let depositDic = newModel.info["deposit"] as? [String: String],
                        let cnMsg = withdraw ? withdrawDic["cnMsg"] : depositDic["cnMsg"],
                     let enMsg = withdraw ? withdrawDic["enMsg"] : depositDic["enMsg"]{
                        trade.cnMsg = cnMsg
                        trade.enMsg = enMsg
                    }

                    trade.tag = newModel.useMemo
                    return trade
                });

                if withdraw {
                    self.store.dispatch(FecthWithdrawIds(data: list))
                } else {
                    self.store.dispatch(FecthDepositIds(data: list))
                }
            }, error: { (_) in

            }) { (_) in

            }
        }
        return gateway2
    }

    func sortedEmptyAsset(_ isEmpty: Bool) {
        self.store.dispatch(SortedByEmptyAssetAction(data: isEmpty))
    }
    func sortedNameAsset(_ name: String) {
        self.store.dispatch(SortedByNameAssetAction(data: name))
    }
}
