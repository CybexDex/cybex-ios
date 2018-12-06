//
//  AppReducer.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwifterSwift

let trackingMiddleware: Middleware<Any> = { dispatch, getState in
    return { next in
        return { action in
            if let action = action as? PageStateAction, let state = getState() as? BaseState {
                state.pageState.accept(action.state)
            } else if let action = action as? RouteContextAction, let state = getState() as? BaseState {
                state.context.accept(action.context)
            } else if let action = action as? RefreshState {
                _ = action.vc?.perform(action.sel)
            }

            return next(action)
        }
    }
}

func loadingReducer(_ state: Bool?, action: Action) -> Bool {
    var state = state ?? false

    switch action {
    case _ as StartLoading:
        state = true
    case _ as EndLoading:
        state = false
    default:
        break
    }

    return state
}

func errorMessageReducer(_ state: String?, action: Action) -> String {
    var state = state ?? ""

    switch action {
    case let action as NetworkErrorMessage:
        state = action.errorMessage
    case _ as CleanErrorMessage:
        state = ""
    default:
        break
    }

    return state
}

func pageReducer(_ state: Int?, action: Action) -> Int {
    var state = state ?? 1

    switch action {
    case _ as NextPage:
        state += 1
    case _ as ResetPage:
        state = 1
    default:
        break
    }
    return state
}

func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(property: appPropertyReducer(state?.property, action: action))
}

let semaphore = DispatchSemaphore(value: 1)

func appPropertyReducer(_ state: AppPropertyState?, action: Action) -> AppPropertyState {
    var state = state ?? AppPropertyState()

    var ids = state.subscribeIds ?? [:]
    var refreshTimes = state.pairsRefreshTimes ?? [:]
    var klineDatas = state.detailData ?? [:]

    switch action {
        //    case let action as MarketsFetched:
        //        async {
        //            if s.wait(timeout: .distantFuture) == .success {
        //
        //                let (matrixs, data) = applyMarketsToState(state, action: action)
        //                main {
        //                    state.matrixs.accept(matrixs)
        //                    state.data.accept(data)
        //                    refreshTimes[Pair(base:action.pair.firstAssetId, quote:action.pair.secondAssetId)] = Date().timeIntervalSince1970
        //                    state.pairsRefreshTimes = refreshTimes
        //                    s.signal()
        //                }
        //            }
        //        }

    case let action as SubscribeSuccess:
        ids[action.pair] = action.id
        refreshTimes[action.pair] = Date().timeIntervalSince1970
        state.subscribeIds = ids
        state.pairsRefreshTimes = refreshTimes

    case let action as AssetInfoAction:
        state.assetInfo[action.assetID] = action.info
    case let action as KLineFetched:

        if klineDatas.has(key: action.pair) {
            var klineData = klineDatas[action.pair]!
            klineData[action.stick] = action.assets
            klineDatas[action.pair] = klineData
        } else {
            klineDatas[action.pair] = [action.stick: action.assets]
        }
        state.detailData = klineDatas
    case let action as FecthEthToRmbPriceAction:
        if action.price.count > 0 {
            for rmbPrices in action.price {
                if rmbPrices.name == "CYB" {
                    if rmbPrices.rmbPrice != "" && rmbPrices.rmbPrice != "0"{
                        state.cybRmbPrice = rmbPrices.rmbPrice.decimal()
                    }
                } else if rmbPrices.name == "BTC" {
                    if rmbPrices.rmbPrice != "" && rmbPrices.rmbPrice != "0"{
                        state.btcRmbPrice = rmbPrices.rmbPrice.decimal()
                    }
                } else if rmbPrices.name == "USDT" {
                    if rmbPrices.rmbPrice != "" && rmbPrices.rmbPrice != "0"{
                        state.usdtRmbPrice = rmbPrices.rmbPrice.decimal()
                    }
                } else if rmbPrices.name == "ETH" {
                    if rmbPrices.rmbPrice != "" && rmbPrices.rmbPrice != "0"{
                        state.ethRmbPrice = rmbPrices.rmbPrice.decimal()
                    }
                }
            }
        }
        state.rmbPrices = action.price
    case let action as FecthMarketListAction:
        state.importMarketLists = action.data

    case let action as TickerFetched:
        async {
            if semaphore.wait(timeout: .distantFuture) == .success {
                main {
                    refreshTimes[Pair(base: action.asset.base, quote: action.asset.quote)] = Date().timeIntervalSince1970
                    state.tickerData.accept(applyTickersToState(state, action: action))
                    semaphore.signal()
                }
            }
        }

    default:
        break
    }

    return state
}

func applyTickersToState(_ state: AppPropertyState, action: TickerFetched) -> [Ticker] {
    var data = state.tickerData.value
    guard  let _ = state.assetInfo[action.asset.base], let _ = state.assetInfo[action.asset.quote] else {
        return data
    }
    if data.count == 0 {
        data.append(action.asset)
    }
    let (contain, index) = data.containHashable(action.asset)
    if !contain {
        data.append(action.asset)
    } else {
        data[index] = action.asset
    }

    if data.count > 1 {
        let scored = data.sorted(by: {return $0.baseVolume.decimal() > $1.baseVolume.decimal()})
        return scored
    } else {
        return data
    }
}

