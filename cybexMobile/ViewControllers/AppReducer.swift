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


func appPropertyReducer(_ state: AppPropertyState?, action: Action) -> AppPropertyState {
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
        state.tickerData.accept(applyTickersToState(state, action: action))
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

