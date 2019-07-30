//
//  WithdrawAddressHomeCoordinator.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import NBLCommonModule
import SwiftyJSON
import HandyJSON

protocol WithdrawAddressHomeCoordinatorProtocol {
    func openWithDrawAddressVC()
}

protocol WithdrawAddressHomeStateManagerProtocol {
    var state: WithdrawAddressHomeState { get }

    func fetchData()
    func fetchAddressData()
    func selectCell(_ index: Int)
}

class WithdrawAddressHomeCoordinator: NavCoordinator {
    var store = Store<WithdrawAddressHomeState>(
        reducer: withdrawAddressHomeReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )

    override func register() {
        Broadcaster.register(WithdrawAddressHomeCoordinatorProtocol.self, observer: self)
        Broadcaster.register(WithdrawAddressHomeStateManagerProtocol.self, observer: self)
    }
}

extension WithdrawAddressHomeCoordinator: WithdrawAddressHomeCoordinatorProtocol {
    func openWithDrawAddressVC() {
        let vc = R.storyboard.account.withdrawAddressViewController()!
        let coor = WithdrawAddressCoordinator(rootVC: self.rootVC)
        vc.coordinator = coor
        if let viewModel = self.state.selectedViewModel.value {
            vc.asset = viewModel.viewModel.model.id
        }
        self.rootVC.pushViewController(vc, animated: true)
    }
}

extension WithdrawAddressHomeCoordinator: WithdrawAddressHomeStateManagerProtocol {
    var state: WithdrawAddressHomeState {
        return store.state
    }

    func fetchData() {
        if checkAndfetchFromGateway2() {
            return
        }

        AppService.request(target: AppAPI.withdrawList, success: { (json) in
            let list = JSON(json).arrayValue.compactMap({ Trade.deserialize(from: $0.dictionaryObject) })
            self.store.dispatch(FecthWithdrawIds(data: list))
        }, error: { (_) in

        }) { (_) in

        }
    }

    func checkAndfetchFromGateway2() -> Bool {
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
                    trade.enable = newModel.withdrawSwitch
                    if let withdrawDic = newModel.info["withdraw"] as? [String: String],
                        let cnMsg = withdrawDic["cnMsg"],
                        let enMsg = withdrawDic["enMsg"] {
                        trade.cnMsg = cnMsg
                        trade.enMsg = enMsg
                    }

                    trade.tag = newModel.useMemo
                    return trade
                });

                self.store.dispatch(FecthWithdrawIds(data: list))
            }, error: { (_) in

            }) { (_) in

            }
        }
        return gateway2
    }

    func fetchAddressData() {
        guard self.state.data.value.count > 0 else { return }

        var data: [String: [WithdrawAddress]] = [:]

        for viewmodel in self.state.data.value {
            data[viewmodel.model.id] = AddressManager.shared.getWithDrawAddressListWith(viewmodel.model.id)
        }

        DispatchQueue.main.async {
            self.store.dispatch(WithdrawAddressHomeAddressDataAction(data: data))
        }
    }

    func selectCell(_ index: Int) {
        self.store.dispatch(WithdrawAddressHomeSelectedAction(index: index))
    }
}
