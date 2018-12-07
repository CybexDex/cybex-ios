//
//  RechargeRecodeCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import HandyJSON

protocol RechargeRecodeCoordinatorProtocol {
    func openRecordDetailUrl(_ hash: String, asset: String)
}

protocol RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState { get }

    func fetchRechargeRecodeList(_ accountName: String, asset: String, fundType: FundType, size: Int, offset: Int, expiration: Int, assetId: String, callback:@escaping (Bool) -> Void)

    func setAssetAction(_ asset: String)

    func fetchAssetUrl()
}

class RechargeRecodeCoordinator: NavCoordinator {
    var store = Store<RechargeRecodeState>(
        reducer: rechargeRecodeReducer,
        state: nil,
        middleware: [trackingMiddleware]
    )
}

extension RechargeRecodeCoordinator: RechargeRecodeCoordinatorProtocol {
    func openRecordDetailUrl(_ hash: String, asset: String) {
        guard let explorers = self.state.explorers.value else { return }
        var url = ""
        for explorer in explorers {
            if explorer.asset.filterJade == asset {
                url = explorer.explorer + hash
            }
        }
        if url.count == 0 {
            for explorer in explorers {
                if explorer.asset.filterJade == "ETH" {
                    url = explorer.explorer + hash
                }
            }
        }
        if let recordVC = self.rootVC.topViewController as? WithdrawAndDespoitRecordViewController {
            recordVC.coordinator?.openRecordDetailUrl(url)
        } else {
            if let webVC = R.storyboard.main.cybexWebViewController() {
                webVC.coordinator = CybexWebCoordinator(rootVC: self.rootVC)
                webVC.vcType = .recordDetail
                webVC.url = URL(string: url)
                self.rootVC.pushViewController(webVC, animated: true)
            }
        }
    }
}

extension RechargeRecodeCoordinator: RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState {
        return store.state
    }

    func fetchRechargeRecodeList(_ accountName: String,
                                 asset: String,
                                 fundType: FundType,
                                 size: Int,
                                 offset: Int,
                                 expiration: Int,
                                 assetId: String,
                                 callback:@escaping (Bool) -> Void) {

        GatewayQueryService.request(target: .login(accountName: accountName), success: { (_) in
            GatewayQueryService.request(target: .records(accountName: accountName, asset: asset, fundType: fundType, offset: offset), success: { (json) in
                
                if let data = TradeRecord.deserialize(from: json.dictionaryObject) {
                    self.store.dispatch(FetchDepositRecordsAction(data: data))
                    callback(true)
                } else {
                    callback(false)
                }
            }, error: { (_) in
                callback(false)
            }, failure: { (_) in
                callback(false)
            })
        }, error: { (_) in
            callback(false)
        }) { (_) in
            callback(false)
        }

    }

    func setAssetAction(_ asset: String) {
        self.store.dispatch(SetWithdrawListAssetAction(asset: asset))
    }

    func fetchAssetUrl() {
        SimpleHTTPService.fetchBlockexplorerJson().done { [weak self](explorers) in
            guard let self = self else { return }
            self.store.dispatch(FetchAssetUrlAction(data: explorers))
            }.catch { (_) in
        }
    }
}
