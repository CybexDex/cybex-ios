//
//  MarketConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import RxCocoa
import SwiftyJSON

enum ExchangeType {
    case buy
    case sell
}

enum Indicator: String {
    case none
    case macd = "MACD"
    case ema = "EMA"
    case ma = "MA"
    case boll = "BOLL"

    static let all: [Indicator] = [.ma, .ema, .macd, .boll]
}

enum Candlesticks: Int, Hashable {
    case fiveMinute = 300
    case oneHour = 3600
    case oneDay = 86400

    static func ==(lhs: Candlesticks, rhs: Candlesticks) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    var hashValue: Int {
        return self.rawValue
    }

    static let all: [Candlesticks] = [.fiveMinute, .oneHour, .oneDay]
}

class MarketConfiguration {
    static let shared = MarketConfiguration()

    var marketPairs: BehaviorRelay<[Pair]> = BehaviorRelay(value: []) //首页过滤白名单后的所有交易对
    var tradePairPrecisions: BehaviorRelay<[Pair: PairPrecision]> = BehaviorRelay(value: [:]) //深度图精度
    var importMarketLists: BehaviorRelay<[ImportantMarketPair]> = BehaviorRelay(value: [])

    private init() {
        
    }

    //行情页面base列表
    static var marketBaseAssets: [AssetConfiguration.CybexAsset] {
        return Defaults.isTestEnv ?
            [AssetConfiguration.CybexAsset.ETH,
             AssetConfiguration.CybexAsset.CYB,
             AssetConfiguration.CybexAsset.BTC] :

            [AssetConfiguration.CybexAsset.ETH,
             AssetConfiguration.CybexAsset.CYB,
             AssetConfiguration.CybexAsset.USDT,
             AssetConfiguration.CybexAsset.BTC]
    }
}

extension MarketConfiguration {
    func fetchMarketPairList() {
        var pairs: [Pair] = []
        var count = 0

        for base in MarketConfiguration.marketBaseAssets.map({ $0.id }) {
            AppService.request(target: AppAPI.marketlist(base: base), success: { (json) in
                let result = json.arrayValue.compactMap({ Pair(base: base, quote: $0.stringValue) })

                let piecePair = result.filter({ (pair) -> Bool in
                    return AssetConfiguration.shared.whiteListOfIds.value.contains([pair.base, pair.quote])
                })

                count += 1
                pairs += piecePair
                if count == MarketConfiguration.marketBaseAssets.count {
                    MarketConfiguration.shared.marketPairs.accept(pairs)
                }
            }, error: { (_) in

            }, failure: { (_) in

            })
        }
    }

    func fetchTopStickMarkets() {
        AppService.request(target: AppAPI.stickTopMarketPair, success: { (json) in
            let marketLists = JSON(json).arrayValue.compactMap({ (item) in
                ImportantMarketPair(base: item["base"].stringValue, quotes: (item["quotes"].arrayObject as? [String])!)
            })

            self.importMarketLists.accept(marketLists)
        }, error: { (_) in

        }, failure: { (_) in

        })
    }
}
