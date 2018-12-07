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
            async {
                let data = try? await(GatewayService.shared.getDepositAddress(accountName: name, assetName: assetName))
                main {
                    if case let data?? = data {
                        self.store.dispatch(FetchAddressInfo(data: data))
                    } else {
                        self.state.data.accept(nil)
                    }
                }
            }
        }
    }

    func resetDepositAddress(_ assetName: String) {
        if let name = UserManager.shared.name.value {
            async {
                let data = try? await(GatewayService.shared.updateDepositAddress(accountName: name, assetName: assetName))
                main {
                    if case let data?? = data {
                        self.store.dispatch(FetchAddressInfo(data: data))
                    } else {
                        self.state.data.accept(nil)
                    }
                }
            }
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
        async {
            let data = try? await(SimpleHTTPService.fetchWorldsInfoWithAssetId(assetId, url:         AppConfiguration.shared.depositWordJson(assetId)))
            main {
                if case let data?? = data {
                    self.store.dispatch(FetchMsgInfo(data: data))
                }
                else {
                    self.state.msgInfo.accept(nil)
                }
            }
        }
    }
}

extension WithdrawDetailCoordinator: WithdrawDetailStateManagerProtocol {
    var state: WithdrawDetailState {
        return store.state
    }
}
