//
//  AssetConfigration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SwiftyJSON
import RxCocoa

class AssetConfiguration {
    //base asset name
    static let JadeSymbol = "JADE"
    static let ArenaSymbol = "ARENA"

    enum CybexAsset: String, CaseIterable {
        case CYB
        case BTC
        case ETH
        case USDT
        case XRP
        case EOS

        case ArenaETH
        case ArenaEOS
        case ArenaUSDT
        case ArenaBTC

        
        var id: String {
            switch self {
            case .CYB:
                return "1.3.0"
            case .BTC:
                return Defaults.isTestEnv ? "1.3.58" : "1.3.3"
            case .ETH:
                return Defaults.isTestEnv ? "1.3.53" : "1.3.2"
            case .USDT:
                return Defaults.isTestEnv ? "1.3.56" : "1.3.27"
            case .XRP:
                return Defaults.isTestEnv ? "1.3.999" : "1.3.999"
            case .EOS:
                return Defaults.isTestEnv ? "1.3.57" : "1.3.4"
            //交易大赛
            case .ArenaEOS:
                return Defaults.isTestEnv ? "1.3.1146" : "1.3.1150"
            case .ArenaBTC:
                return Defaults.isTestEnv ? "1.3.1147" : "1.3.1151"
            case .ArenaETH:
                return Defaults.isTestEnv ? "1.3.1144" : "1.3.1149"
            case .ArenaUSDT:
                return Defaults.isTestEnv ? "1.3.1145" : "1.3.1148"
            }
        }

        var name: String {
            switch self {
            //交易大赛
            case .ArenaEOS:
                return AssetConfiguration.ArenaSymbol + "." + "EOS"
            case .ArenaBTC:
                return AssetConfiguration.ArenaSymbol + "." + "BTC"
            case .ArenaETH:
                return AssetConfiguration.ArenaSymbol + "." + "ETH"
            case .ArenaUSDT:
                return AssetConfiguration.ArenaSymbol + "." + "USDT"
            default:
                return self.rawValue
            }
        }
    }

    static let shared = AssetConfiguration()
    var whiteListOfIds: BehaviorRelay<[String]> = BehaviorRelay(value: []) //白名单资产id
    //quote对应全称
    var quoteToProjectNames: BehaviorRelay<[String : String]> = BehaviorRelay(value: [:])

    private var baseRmbPrices: [CybexAsset: Decimal] = [:] //assetid:rmb

    private init() {
        _ = AppConfiguration.shared.rmbPrices.asObservable().subscribe(onNext: { (prices) in
            self.handlerRMBPrices(prices)
        })
    }

    func rmbOf(asset: CybexAsset) -> Decimal {
        return baseRmbPrices[asset] ?? 0
    }
}

extension AssetConfiguration.CybexAsset {
    init?(_ id: String) {
        let all = AssetConfiguration.CybexAsset.allCases
        let ids = all.map({ $0.id })

        if let index = ids.lastIndex(of: id) {
            self = all[index]
        }
        else {
            return nil
        }
    }
}

extension AssetConfiguration {
    func fetchWhiteListAssets() {
        AppService.request(target: AppAPI.assetWhiteList, success: { (json) in
            let data = JSON(json).arrayValue.compactMap({ String(describing: $0.stringValue) })

            var otherIds: [String] = []
            if let gameEnable = AppConfiguration.shared.enableSetting.value?.contestEnabled, gameEnable {
                let gameIds = MarketConfiguration.shared.gameMarketPairs.map { $0.quote } + MarketConfiguration.gameMarketBaseAssets.map { $0.id }
                otherIds.append(contentsOf: gameIds)
            }

            AssetConfiguration.shared.whiteListOfIds.accept(data + otherIds)
        }, error: { (_) in

        }) { (_) in

        }
    }
    
    func fetchQuoteToProjectNames() {
        AppService.request(target: AppAPI.evaluapeSetting, success: { (json) in
            guard let result = json.dictionaryObject as? [String : String] else { return }
            AssetConfiguration.shared.quoteToProjectNames.accept(result)
        }, error: { (_) in
            
        }) { (_) in
            
        }
    }

    func handlerRMBPrices(_ prices: [RMBPrices]) {
        for rmbPrice in prices {
            if let asset = CybexAsset(rawValue: rmbPrice.name), rmbPrice.value != "", rmbPrice.value != "0" {
                baseRmbPrices[asset] = rmbPrice.value.decimal()
            }
        }
    }
}

extension String {
    var originSymbol: String {
        return appData.assetInfo[self]?.symbol ?? self
    }

    var symbol: String {
        return symbolOnlyFilterJade.filterArena
    }

    var symbolOnlyFilterJade: String {
        return appData.assetInfo[self]?.symbol.filterOnlyJade ?? self
    }
    
    var precision: Int {
        return appData.assetInfo[self]?.precision ?? 0
    }
    
    var assetID: String {
        return appData.assetNameToIds.value[self] ?? self
    }
}
