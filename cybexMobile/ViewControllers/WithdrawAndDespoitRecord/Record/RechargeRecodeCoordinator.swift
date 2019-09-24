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
import SwiftyJSON

protocol RechargeRecodeCoordinatorProtocol {
    func openRecordDetailUrl(_ hash: String, asset: String)
}

protocol RechargeRecodeStateManagerProtocol {
    var state: RechargeRecodeState { get }

    func fetchRechargeRecodeList(_ accountName: String, asset: String, fundType: FundType, size: Int, offset: Int, expiration: Int, callback:@escaping (Bool) -> Void)

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
            if explorer.asset.filterSystemPrefix == asset {
                url = explorer.explorer + hash
            }
        }
        if url.count == 0 {
            for explorer in explorers {
                if explorer.asset.filterSystemPrefix == AssetConfiguration.CybexAsset.ETH.name {
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
                                 callback:@escaping (Bool) -> Void) {
        guard let setting = AppConfiguration.shared.enableSetting.value else {
            callback(false)
            return
        }

        let gateway2 = setting.gateWay2
        if gateway2 {
            var fromId: Int? = nil
            if offset > 0, let records = self.state.data.value?.records, records.count > 0, let id = records.last?.details?.first?.id.int {
                fromId = id
            }
            Gateway2Service.request(target: .transactions(fundType: fundType, assetName: asset.filterOnlySystemPrefix, userName: accountName, fromId: fromId), success: { (json) in

                let data = json["records"].arrayValue.map({ (record) -> Record in
                    let model = GatewayTransactionResponseModel.deserialize(from: record.dictionaryObject)!
                    var oldRecord = Record()
                    oldRecord.address = model.outAddr
                    if let assetID = AssetHelper.getAssetId(model.cybexAsset.filterSystemPrefix) {
                        let amount = AssetHelper.setRealAmount(assetID, amount: model.totalAmount).intValue
                        oldRecord.amount = amount
                    }
                    oldRecord.asset = model.cybexAsset.filterSystemPrefix
                    oldRecord.fundType = model.type
                    oldRecord.state = model.status.rawValue.lowercased()
                    oldRecord.updateAt = model.updatedAt
                    oldRecord.details = [RecordDetail(id: model.id.string, state: "", hash: model.outHash)]
                    return oldRecord
                })

                var tradeRecord = TradeRecord()
                tradeRecord.total = json["total"].intValue
                tradeRecord.size = json["size"].intValue
                tradeRecord.offset = offset
                tradeRecord.records = data

                self.store.dispatch(FetchDepositRecordsAction(data: tradeRecord))
                callback(true)
            }, error: { (_) in
                callback(false)
            }) { (_) in
                callback(false)
            }
            return
        }

    }

    func setAssetAction(_ asset: String) {
        self.store.dispatch(SetWithdrawListAssetAction(asset: asset))
    }

    func fetchAssetUrl() {
        AppService.request(target: AppAPI.explorerURL, success: { (json) in
            let explorers = json.arrayValue.compactMap({ (item) -> BlockExplorer in
                return BlockExplorer(asset: item["asset"].stringValue, explorer: item["explorer"].stringValue)
            })
            self.store.dispatch(FetchAssetUrlAction(data: explorers))
        }, error: { (_) in

        }) { (_) in

        }
    }
}
