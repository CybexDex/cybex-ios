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
//    var data:BehaviorRelay<[HomeBucket]> = BehaviorRelay(value: [])
    var ticker_data: BehaviorRelay<[Ticker]> = BehaviorRelay(value: [])

    var matrixs: BehaviorRelay<[Pair: BucketMatrix]> = BehaviorRelay(value: [:])

    var detailData: [Pair: [candlesticks: [Bucket]]]?

    var subscribeIds: [Pair: Int]?
    var pairsRefreshTimes: [Pair: Double]?

    var otherRequestRelyData: BehaviorRelay<Int?> = BehaviorRelay(value: nil)

    var assetInfo: [String: AssetInfo] = [:]

    var rmb_prices: [RMBPrices] = []

//    var eth_rmb_price: Double = 0
    var cyb_rmb_price: Double = 0

    var importMarketLists: [ImportantMarketPair] = []

    func filterQuoteAssetTicker(_ base: String) -> [Ticker] {
        return self.ticker_data.value.filter({ (currency) -> Bool in
            return currency.base == base
        })
    }

    func filterPopAssetsCurrency() -> [Ticker] {
        let counts = self.ticker_data.value.filter { (currency) -> Bool in
            return !currency.percent_change.contains("-")
        }
        return counts.sorted(by: { (currency1, currency2) -> Bool in
            let change1 = currency1.percent_change
            let change2 = currency2.percent_change
            return change1.toDecimal()! > change2.toDecimal()!
        })
    }

}

struct HomeBucket: Equatable, Hashable {
    let base: String
    let quote: String
    var bucket: [Bucket]
    let base_info: AssetInfo
    let quote_info: AssetInfo

    public static func == (lhs: HomeBucket, rhs: HomeBucket) -> Bool {
        return lhs.base == rhs.base && lhs.quote == rhs.quote && lhs.bucket == rhs.bucket && lhs.base_info == rhs.base_info && lhs.quote_info == rhs.quote_info
    }

    var hashValue: Int {
        let value = base.hashValue < quote.hashValue ? -1 : 1
        let valueStr = "\(base.hashValue)" + "+" + "\(quote.hashValue)"
        return value * valueStr.hashValue
    }
}

struct Pair: Hashable {
    let base: String
    let quote: String
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

struct FecthMarketListAction: Action {
    var data: [ImportantMarketPair]
}

struct MarketsFetched: Action {
    let pair: AssetPairQueryParams
    let assets: [Bucket]
}

struct TickerFetched: Action {
    let asset: Ticker
}

struct kLineFetched: Action {
    let pair: Pair
    let stick: candlesticks
    let assets: [Bucket]
}

struct RefreshState: Action {
    let sel: Selector
    let vc: BaseViewController?
}

struct SubscribeSuccess: Action {
    let pair: Pair
    let id: Int
}

struct AssetInfoAction: Action {
    let assetID: String
    let info: AssetInfo
}

struct FecthEthToRmbPriceAction: Action {
    let price: [RMBPrices]
}
struct FecthUSDTToRmbPriceAction: Action {
    let price: Double
}

typealias MarketDataCallback = ([Bucket]) -> Void
typealias CurrencyDataCallback = (Ticker) -> Void

class AppPropertyActionCreate: LoadingActionCreator {
    public typealias ActionCreator = (_ state: AppState, _ store: Store<AppState>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: AppState,
        _ store: Store <AppState>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void

    func fetchMarket(with sub: Bool = true, params: AssetPairQueryParams, priority: Operation.QueuePriority = .normal, callback: MarketDataCallback?) -> ActionCreator {
        return { state, store in
            self.fetchingMarketList(params, priority: priority, callback: {[weak self] (res) in
                guard let `self` = self else { return }

                if var assets = res as? [Bucket] {
                    if assets.count > 0 {
                        let asset = assets[0]

                        if asset.open > params.startTime.timeIntervalSince1970 {

                            self.cycleFetch(asset, params: params, priority: priority, callback: { (o_asset) in
                                if let o_asset = o_asset as? Bucket {
                                    let close = o_asset.open_base
                                    let quote_close = o_asset.open_quote
                                    let addAsset = asset.copy() as! Bucket

                                    let gapCount = ceil((asset.open - params.startTime.timeIntervalSince1970) / Double(asset.seconds)!)
                                    addAsset.close_base = close
                                    addAsset.close_quote = quote_close
                                    addAsset.open_base = close
                                    addAsset.open_quote = quote_close
                                    addAsset.high_base = close
                                    addAsset.high_quote = quote_close
                                    addAsset.low_base = close
                                    addAsset.low_quote = quote_close
                                    addAsset.base_volume = "0"
                                    addAsset.quote_volume = "0"
                                    addAsset.open = asset.open - gapCount * Double(asset.seconds)!
                                    assets.prepend(addAsset)
                                }
                                callback?(assets)
                            })
                        } else {
                            callback?(assets)
                        }
                    } else {
                        callback?([])
                    }
                } else {
                }
            })
            if sub {

            }
            return nil

        }
    }

    func fetchCurrencyList(_ params: AssetPairQueryParams, priority: Operation.QueuePriority = .normal, callback: CurrencyDataCallback?) {
        let request = GetTickerRequest(baseName: params.firstAssetId, quoteName: params.secondAssetId) { response in
            if let callback = callback, let data = response as? Ticker {
                callback(data)
            }
        }
        CybexWebSocketService.shared.send(request: request, priority: priority)
    }

    func fetchingMarketList(_  params: AssetPairQueryParams, priority: Operation.QueuePriority = .normal, callback: CommonAnyCallback?) {

        let request = GetMarketHistoryRequest(queryParams: params) { response in
            if let callback = callback {
                callback(response)
            }
        }

        CybexWebSocketService.shared.send(request: request, priority: priority)
    }

    func cycleFetch(_ asset: Bucket, params: AssetPairQueryParams, priority: Operation.QueuePriority = .normal, callback: CommonAnyCallback?) {
        var re_params = params
        re_params.startTime = params.startTime.addingTimeInterval(-24 * 3600)
        re_params.endTime = params.startTime
        self.fetchingMarketList(re_params, priority: priority, callback: {[weak self] (o_res) in
            guard let `self` = self else { return }
            if let o_assets = o_res as? [Bucket] {
                if o_assets.count > 0, let o_asset = o_assets.last {
                    if let callback = callback {
                        callback(o_asset)
                    }
                } else if o_assets.count > 0 {
                    self.cycleFetch(asset, params: re_params, callback: callback)
                } else {
                    if let callback = callback {
                        callback(0)
                    }
                }
            }
        })
    }

}
