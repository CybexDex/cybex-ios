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

func loadingReducer(_ state: Bool?, action: ReSwift.Action) -> Bool {
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

func errorMessageReducer(_ state: String?, action: ReSwift.Action) -> String {
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

func pageReducer(_ state: Int?, action: ReSwift.Action) -> Int {
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

func appReducer(action: ReSwift.Action, state: AppState?) -> AppState {
    return AppState(property: appPropertyReducer(state?.property, action: action))
}


func appPropertyReducer(_ state: AppPropertyState?, action: ReSwift.Action) -> AppPropertyState {
    var state = state ?? AppPropertyState()

    switch action {
    case let action as AssetInfoAction:
        var assetinfoMap: [String: AssetInfo] = [:]
        var nameToIds: [String: String] = [:]

        for info in action.info {
            assetinfoMap[info.id] = info
            nameToIds[info.symbol.filterOnlySystemPrefix] = info.id
        }
        state.assetInfo = assetinfoMap
        state.assetNameToIds.accept(nameToIds)

    case let action as TickerFetched:
        state.tickerData.accept(applyTickersToState(state, ticker: action.asset))
    case let action as TickerBatchFetched:
        let data = action.assets
        if data.count > 1 {
            let scored = data.sorted(by: {return $0.baseVolume.decimal() > $1.baseVolume.decimal()})
            state.tickerData.accept(scored)
        }
        state.tickerData.accept(data)

    default:
        break
    }

    return state
}

func applyTickersToState(_ state: AppPropertyState, ticker: Ticker) -> [Ticker] {
    var data = state.tickerData.value
    guard  let _ = state.assetInfo[ticker.base], let _ = state.assetInfo[ticker.quote] else {
        return data
    }
    if data.count == 0 {
        data.append(ticker)
    }
    let (contain, index) = data.containHashable(ticker)
    if !contain {
        data.append(ticker)
    } else {
        data[index] = ticker
    }

    if data.count > 1 {
        let scored = data.sorted(by: {return $0.baseVolume.decimal() > $1.baseVolume.decimal()})
        return scored
    } else {
        return data
    }
}

