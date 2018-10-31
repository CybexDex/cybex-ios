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
    var tickerData: BehaviorRelay<[Ticker]> = BehaviorRelay(value: [])

    var matrixs: BehaviorRelay<[Pair: BucketMatrix]> = BehaviorRelay(value: [:])

    var detailData: [Pair: [Candlesticks: [Bucket]]]?

    var subscribeIds: [Pair: Int]?
    var pairsRefreshTimes: [Pair: Double]?

    var otherRequestRelyData: BehaviorRelay<Int?> = BehaviorRelay(value: nil)

    var assetInfo: [String: AssetInfo] = [:]

    var rmbPrices: [RMBPrices] = []

//    var eth_rmb_price: Double = 0
    var cybRmbPrice: Double = 0

    var importMarketLists: [ImportantMarketPair] = []

    func filterQuoteAssetTicker(_ base: String) -> [Ticker] {
        return self.tickerData.value.filter({ (currency) -> Bool in
            return currency.base == base
        })
    }

    func filterPopAssetsCurrency() -> [Ticker] {
        let counts = self.tickerData.value.filter { (currency) -> Bool in
            return !currency.percentChange.contains("-")
        }
        return counts.sorted(by: { (currency1, currency2) -> Bool in
            let change1 = currency1.percentChange
            let change2 = currency2.percentChange
            return change1.toDecimal()! > change2.toDecimal()!
        })
    }

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

struct KLineFetched: Action {
    let pair: Pair
    let stick: Candlesticks
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
                            self.cycleFetch(asset, params: params, priority: priority, callback: { (oAsset) in
                                if let oAsset = oAsset as? Bucket {
                                    let close = oAsset.openBase
                                    let quoteClose = oAsset.openQuote
                                    if let addAsset = asset.copy() as? Bucket {
                                        let gapCount = ceil((asset.open - params.startTime.timeIntervalSince1970) / Double(asset.seconds)!)
                                        addAsset.closeBase = close
                                        addAsset.closeQuote = quoteClose
                                        addAsset.openBase = close
                                        addAsset.openQuote = quoteClose
                                        addAsset.highBase = close
                                        addAsset.highQuote = quoteClose
                                        addAsset.lowBase = close
                                        addAsset.lowQuote = quoteClose
                                        addAsset.baseVolume = "0"
                                        addAsset.quoteVolume = "0"
                                        addAsset.open = asset.open - gapCount * Double(asset.seconds)!
                                        assets.prepend(addAsset)
                                    }
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

    func cycleFetch(_ asset: Bucket,
                    params: AssetPairQueryParams,
                    priority: Operation.QueuePriority = .normal,
                    callback: CommonAnyCallback?) {
        var reParams = params
        reParams.startTime = params.startTime.addingTimeInterval(-24 * 3600)
        reParams.endTime = params.startTime
        self.fetchingMarketList(reParams, priority: priority, callback: {[weak self] (oRes) in
            guard let `self` = self else { return }
            if let oAssets = oRes as? [Bucket] {
                if oAssets.count > 0, let oAssetLast = oAssets.last {
                    if let callback = callback {
                        callback(oAssetLast)
                    }
                } else if oAssets.count > 0 {
                    self.cycleFetch(asset, params: reParams, callback: callback)
                } else {
                    if let callback = callback {
                        callback(0)
                    }
                }
            }
        })
    }

}
