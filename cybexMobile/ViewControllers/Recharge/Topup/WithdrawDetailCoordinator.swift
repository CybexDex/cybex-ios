//
//  WithdrawDetailCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import Localize_Swift
import HandyJSON
import SwiftyJSON

protocol WithdrawDetailCoordinatorProtocol {
    func fetchDepositAddress(_ assetName: String)
    func resetDepositAddress(_ assetName: String)
    func openDepositRecode(_ assetId: String)
    func fetchDepositWordInfo(_ assetId: String)
}

protocol WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState { get }
}

class WithdrawDetailCoordinator: NavCoordinator {
    var store = Store<WithdrawDetailState>(
        reducer: withdrawDetailReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension WithdrawDetailCoordinator: WithdrawDetailCoordinatorProtocol {
    func fetchDepositAddress(_ assetName: String) {
        if let name = UserManager.shared.name.value {
            guard let setting = AppConfiguration.shared.enableSetting.value else {
                return
            }

            let gateway2 = setting.gateWay2
            if gateway2 {
                Gateway2Service.request(target: .topUPAddress(assetName: assetName, userName: name), success: { (json) in
                    let info = AccountAddressRecord(accountName: name, address: json["address"].stringValue, asset: assetName)
                    self.store.dispatch(FetchAddressInfo(data: info))
                }, error: { (_) in

                }) { (_) in

                }
                return
            }

            GatewayService().getDepositAddress(accountName: name, assetName: assetName).done { (data) in
                if case let data? = data {
                    self.store.dispatch(FetchAddressInfo(data: data))
                } else {
                    self.state.data.accept(nil)
                }
            }.cauterize()
        }
    }

    func resetDepositAddress(_ assetName: String) {
        if let name = UserManager.shared.name.value {
            GatewayService().updateDepositAddress(accountName: name, assetName: assetName).done { (data) in
                if case let data? = data {
                    self.store.dispatch(FetchAddressInfo(data: data))
                } else {
                    self.state.data.accept(nil)
                }
            }.cauterize()
        }
    }

    func openDepositRecode(_ assetId: String) {
        if let vc = R.storyboard.recode.rechargeRecodeViewController() {
            vc.recordType = .DEPOSIT
            vc.assetInfo = appData.assetInfo[assetId]
            vc.coordinator = RechargeRecodeCoordinator(rootVC: self.rootVC)
            self.rootVC.pushViewController(vc, animated: true)
        }
    }
    
    func fetchDepositWordInfo(_ assetId: String) {
        AppService.request(target: AppAPI.topUpAnnounce(assetId: assetId), success: { (json) in
            if let data = RechargeWorldInfo.deserialize(from: json.dictionaryObject) {
                self.store.dispatch(FetchMsgInfo(data: data))
            }
            else {
                self.state.msgInfo.accept(nil)
            }
        }, error: { (_) in

        }) { (_) in

        }
    }
}

extension WithdrawDetailCoordinator: WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState {
        return store.state
    }
}
