//
//  RechargeReducers.swift
//  cybexMobile
//
//  Created DKM on 2018/6/5.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

func rechargeReducer(action: Action, state: RechargeState?) -> RechargeState {
    let state = state ?? RechargeState()

    switch action {
    case let action as FecthDepositIds:
        state.depositData.accept(filterData(action.data))
        state.depositIds.accept(filterData(action.data))

    case let action as FecthWithdrawIds:
        state.withdrawData.accept(filterData(action.data))
        state.withdrawIds.accept(filterData(action.data))

    case let action as SortedByEmptyAssetAction:
        state.isEmpty.accept(action.data)
        state.depositIds.accept(filterEmptyOrSortedNameTrades(state.depositData.value, isEmpty: state.isEmpty.value, name: state.sortedName.value))
        state.withdrawIds.accept(filterEmptyOrSortedNameTrades(state.withdrawData.value, isEmpty: state.isEmpty.value, name: state.sortedName.value))

    case let action as SortedByNameAssetAction:
        state.sortedName.accept(action.data)
        state.depositIds.accept(filterEmptyOrSortedNameTrades(state.depositData.value, isEmpty: state.isEmpty.value, name: state.sortedName.value))
        state.withdrawIds.accept(filterEmptyOrSortedNameTrades(state.withdrawData.value, isEmpty: state.isEmpty.value, name: state.sortedName.value))

    default:
        break
    }
    return state
}

func filterData(_ trades: [Trade]) -> [Trade] {
    let data = trades.filter({return appData.assetInfo[$0.id] != nil})
    var tradesInfo: [Trade] = []
    if var balances = UserManager.shared.balances.value {
        balances = balances.filter { (balance) -> Bool in
            return getRealAmount(balance.assetType, amount: balance.balance).doubleValue != 0
        }
        for balance in balances {
            for var trade in data {
                guard let info = appData.assetInfo[trade.id] else { continue }
                if trade.id == balance.assetType {
                    trade.amount = getRealAmount(balance.assetType,
                                                 amount: balance.balance).string(digits: info.precision,
                                                                                 roundingMode: .down)
                    tradesInfo.append(trade)
                }
            }
        }
        let filterData = data.filter { (trade) -> Bool in
            for tradeInfo in tradesInfo {
                if tradeInfo.id == trade.id {
                    return false
                }
            }
            return true
        }
        return tradesInfo + filterData
    }
    return data
}

func filterEmptyOrSortedNameTrades(_ trades: [Trade], isEmpty: Bool, name: String) -> [Trade] {
    if name.isEmpty {
        if isEmpty {
            return trades.filter({$0.amount != "0"})
        }
        return trades
    } else {
        let data = trades.filter({ (trade) -> Bool in
            guard let tradeInfo = appData.assetInfo[trade.id] else { return false }
            return tradeInfo.symbol.filterJade.contains(name.uppercased())
        })
        if isEmpty {
            return data.filter({$0.amount != "0"})
        }
        return data
    }
}
