//
//  TransferListReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import HandyJSON
import coswift

func transferListReducer(action: ReSwift.Action, state: TransferListState?) -> TransferListState {
    let state = state ?? TransferListState()

    switch action {
    case let action as ReduceTansferRecordsAction :
        transferRecordsToViewModels(action.data) { (result) in
            state.data.accept(result)
        }
        break
    default:
        break
    }

    return state
}

func transferRecordsToViewModels(_ sender: [(TransferRecord, time: String)], callback:@escaping([TransferRecordViewModel]) -> Void) {
    if sender.count == 0 {
        callback([])
    }

    if let uid = UserManager.shared.getCachedAccount()?.id {
        var data: [TransferRecordViewModel] = [TransferRecordViewModel]()
        var assetInfos: [AssetInfo] = []
        var outsideIndex: [Int] = []

        co_launch {
            for (index, source) in sender.enumerated() {
                let isSend = source.0.from == uid
                let requesetId = isSend ? source.0.to : source.0.from
                var outside = false

                let waitFromResult = try await {
                   UserHelper.shared.getName(id: requesetId)
                }

                if case let .fulfilled(result) = waitFromResult {
                    guard let transferAmount = source.0.amount else {
                        continue
                    }

                    if let assetInfo = appData.assetInfo[transferAmount.assetId]
                    {
                        outside = false
                        assetInfos.append(assetInfo)

                    } else {
                        outside = true
                        let info = AssetInfo()
                        info.id = transferAmount.assetId
                        assetInfos.append(info)
                        outsideIndex.append(index)
                    }

                    let transferViewModel = TransferRecordViewModel(isSend: isSend,
                                                                    name: result,
                                                                                       time: Formatter.iso8601.date(from: source.time)!.string(withFormat: "MM/dd HH:mm:ss"),
                                                                                       amount: "--",
                                                                                       memo: source.0.memo?.toJSONString() ?? "",
                                                                                       vestingPeriod: source.0.vestingPeriod.string,
                                                                                       fee: source.0.fee,
                                                                                       outside: outside)

                    data.append(transferViewModel)
                }
            }

            let ids = assetInfos.filter { (item) -> Bool in
                return item.symbol.isEmpty
            }.map { item -> String in
                return item.id
            }

            if ids.count == 0 {
                for (i, info) in assetInfos.enumerated() {
                    guard let transferAmount = sender[i].0.amount else {
                        continue
                    }
                    var origin = data[i]
                    let realAmount = AssetHelper.getRealAmount(transferAmount.assetId, amount: transferAmount.amount)
                    origin.amount = realAmount.formatCurrency(digitNum: info.precision) + " " + info.symbol.filterSystemPrefix
                    origin.amount = (origin.isSend ? "-" : "+") + origin.amount
                    data[i] = origin
                }

                if data.count == sender.count {
                    callback(data)
                }
                return
            }
            let request = GetObjectsRequest(ids: ids, refLib: false) { response in
                if let assetinfo = response as? [AssetInfo] {
                    for (i, info) in assetinfo.enumerated() {
                        assetInfos[outsideIndex[i]] = info
                    }

                    for (i, info) in assetInfos.enumerated() {
                        guard let transferAmount = sender[i].0.amount else {
                            continue
                        }
                        var origin = data[i]

                        let realAmount = transferAmount.amount.decimal() / pow(10, info.precision)
                        origin.amount = realAmount.formatCurrency(digitNum: info.precision) + " " + info.symbol.filterSystemPrefix
                        origin.amount = (origin.isSend ? "-" : "+") + origin.amount
                        data[i] = origin
                    }

                    if data.count == sender.count {
                        callback(data)
                    }
                }
            }
            CybexWebSocketService.shared.send(request: request, priority: .veryHigh)


        }


    }
}
