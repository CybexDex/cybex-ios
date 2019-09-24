//
//  TradeHistoryReducers.swift
//  cybexMobile
//
//  Created koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift
import SwiftyJSON

func tradeHistoryReducer(action: ReSwift.Action, state: TradeHistoryState?) -> TradeHistoryState {
    let state = state ?? TradeHistoryState()

    switch action {
    case let action as FetchedFillOrderData:
        let viewmodels = convertDataToTradeHistoryViewModel(action.pair, data: action.data)
        DispatchQueue.main.async {
            state.data.accept(viewmodels)
        }
    default:
        break
    }
    return state
}

func convertDataToTradeHistoryViewModel(_ pair:Pair, data: [JSON]) -> [TradeHistoryViewModel] {
    var showData: [TradeHistoryViewModel] = []
    let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(pair)
    for itemData in data {
        let curData = itemData

        let operation = curData[0]
        //                let receive = curData[1]
        let time = curData[1].stringValue
        let pay = operation["pays"]
        let receive = operation["receives"]
        let base = operation["fill_price"]["base"]
        let quote = operation["fill_price"]["quote"]
        let baseInfo = appData.assetInfo[pair.base]!
        let quoteInfo = appData.assetInfo[pair.quote]!
        let basePrecision = pow(10, baseInfo.precision)
        let quotePrecision = pow(10, quoteInfo.precision)

        if base["asset_id"].stringValue == pair.base {
            let quoteVolume = Decimal(string: quote["amount"].stringValue)! / quotePrecision
            let baseVolume = Decimal(string: base["amount"].stringValue)! / basePrecision
            let payVolume = Decimal(string: receive["amount"].stringValue)! / quotePrecision
            let receiveVolume = Decimal(string: pay["amount"].stringValue)! / basePrecision

            let price = baseVolume / quoteVolume
            let tradePrice = price.formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)
            let viewModel = TradeHistoryViewModel(
                pay: false,
                price: tradePrice,
                quoteVolume: payVolume.suffixNumber(digitNum: tradePrecision.book.amount.int!),
                baseVolume: receiveVolume.suffixNumber(digitNum: tradePrecision.book.total.int!),
                time: time.dateFromISO8601!.string(withFormat: "HH:mm:ss"))
            showData.append(viewModel)
        } else {
            let quoteVolume = Decimal(string: base["amount"].stringValue)! / quotePrecision
            let baseVolume = Decimal(string: quote["amount"].stringValue)! / basePrecision

            let payVolume = Decimal(string: pay["amount"].stringValue)! / quotePrecision
            let receiveVolume = Decimal(string: receive["amount"].stringValue)! / basePrecision

            let price = baseVolume / quoteVolume

            let tradePrice = price.formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)
            let viewModel = TradeHistoryViewModel(
                pay: true,
                price: tradePrice,
                quoteVolume: payVolume.suffixNumber(digitNum: tradePrecision.book.amount.int!),
                baseVolume: receiveVolume.suffixNumber(digitNum: tradePrecision.book.total.int!),
                time: time.dateFromISO8601!.string(withFormat: "HH:mm:ss"))
            showData.append(viewModel)
        }
    }

    return showData
}
