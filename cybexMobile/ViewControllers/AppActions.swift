//
//  AppActions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa

enum PageRefreshType: Int {
    case initial = 0
    case manual

    func mapReason() -> PageLoadReason {
        switch self {
        case .initial:
            return .initialRefresh
        case .manual:
            return .manualRefresh
        }
    }
}

enum PageLoadReason: Int {
    case initialRefresh = 0
    case manualRefresh
    case manualLoadMore
}

indirect enum PageState {
    case initial
    case loading(reason: PageLoadReason)
    case refresh(type: PageRefreshType)
    case loadMore(page: Int)
    case noMore
    case noData
    case normal(reason: PageLoadReason)
    case error(error: CybexError, reason: PageLoadReason)
}

extension PageState: Equatable {
    static func == (lhs: PageState, rhs: PageState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.refresh(let lhsLast), .refresh(let rhsLast)):
            return lhsLast == rhsLast
        case (.loadMore(let lhsPage), .loadMore(let rhsPage)):
            return lhsPage == rhsPage
        case (.noMore, .noMore):
            return true
        case (.noData, .noData):
            return true
        case (.normal(let lhsLast), .normal(let rhsLast)):
            return lhsLast == rhsLast
        case (.error(let lhsError, _), .error(let rhsError, _)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

protocol BaseState: StateType {
    var pageState: BehaviorRelay<PageState> { get set }
    var context: BehaviorRelay<RouteContext?> { get set }
}

struct AppState: StateType {
    var property: AppPropertyState
}

struct AppPropertyState {
    var tickerData: BehaviorRelay<[Ticker]> = BehaviorRelay(value: [])
//    var pairTickerData: BehaviorRelay<[Pair: Ticker]> = BehaviorRelay(value: [:])
    //base对应的ticker
//    var marketTickerData: BehaviorRelay<[AssetConfiguration.CybexAsset: Ticker]> = BehaviorRelay(value: [:])

    //监听行情刷新
    var otherRequestRelyData: BehaviorRelay<Int?> = BehaviorRelay(value: nil)

    //assetID -> info
    var assetInfo: [String: AssetInfo] = [:]

    //filted Jade
    var assetNameToIds: BehaviorRelay<[String: String]> = BehaviorRelay(value: [:])
}

struct HomeBucket: Equatable, Hashable {
    let base: String
    let quote: String
    var bucket: [Bucket]
    let baseInfo: AssetInfo
    let quoteInfo: AssetInfo

    public static func == (lhs: HomeBucket, rhs: HomeBucket) -> Bool {
        return lhs.base == rhs.base &&
            lhs.quote == rhs.quote &&
            lhs.bucket == rhs.bucket &&
            lhs.baseInfo == rhs.baseInfo &&
            lhs.quoteInfo == rhs.quoteInfo
    }

    var hashValue: Int {
        let value = base.hashValue < quote.hashValue ? -1 : 1
        let valueStr = "\(base.hashValue)" + "+" + "\(quote.hashValue)"
        return value * valueStr.hashValue
    }
}

struct Pair: Hashable {//id
    let base: String
    let quote: String

    var assets: [String] {
        return [base, quote]
    }

    func info(_ asset: String) -> AssetInfo {
        return appData.assetInfo[asset] ?? AssetInfo()
    }

}

class LoadingActionCreator {
}

struct RouteContextAction: Action {
    var context: RouteContext?
}

struct PageStateAction: Action {
    var state: PageState
}

// MARK: - Common Actions
struct StartLoading: Action {
    var vc: BaseViewController?
}
struct EndLoading: Action {
    var vc: BaseViewController?
}

struct NoData: Action {
}

struct NetworkErrorMessage: Action {
    let errorMessage: String
}
struct CleanErrorMessage: Action {}

struct NextPage: Action {}

struct ResetPage: Action {}

struct TickerFetched: Action {
    let asset: Ticker
}

struct RefreshState: Action {
    let sel: Selector
    let vc: BaseViewController?
}

struct AssetInfoAction: Action {
    let info: [AssetInfo]
}

typealias MarketDataCallback = ([Bucket]) -> Void
typealias CurrencyDataCallback = (Ticker) -> Void
