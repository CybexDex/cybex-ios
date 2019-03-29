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
    static var systemSymbol: String {
        switch AppEnv.current {
        case .product:
            return "JADE"
        case .test:
            return "TEST"
        case .uat:
            return "JADE"
        }
    }

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
                switch AppEnv.current {
                case .product:
                    return "1.3.3"
                case .test:
                    return "1.3.3"
                case .uat:
                    return "1.3.3"
                }
            case .ETH:
                switch AppEnv.current {
                case .product:
                    return "1.3.2"
                case .test:
                    return "1.3.2"
                case .uat:
                    return "1.3.2"
                }
            case .USDT:
                switch AppEnv.current {
                case .product:
                    return "1.3.27"
                case .test:
                    return "1.3.23"
                case .uat:
                    return "1.3.27"
                }
            case .XRP:
                switch AppEnv.current {
                case .product:
                    return "1.3.999"
                case .test:
                    return "1.3.999"
                case .uat:
                    return "1.3.999"
                }
            case .EOS:
                switch AppEnv.current {
                case .product:
                    return "1.3.4"
                case .test:
                    return "1.3.4"
                case .uat:
                    return "1.3.4"
                }
            //交易大赛
            case .ArenaEOS:
                switch AppEnv.current {
                case .product:
                    return "1.3.1150"
                case .test:
                    return "1.3.1146"
                case .uat:
                    return "1.3.1150"
                }
            case .ArenaBTC:
                switch AppEnv.current {
                case .product:
                    return "1.3.1151"
                case .test:
                    return "1.3.1147"
                case .uat:
                    return "1.3.1151"
                }
            case .ArenaETH:
                switch AppEnv.current {
                case .product:
                    return "1.3.1149"
                case .test:
                    return "1.3.1144"
                case .uat:
                    return "1.3.1149"
                }
            case .ArenaUSDT:
                switch AppEnv.current {
                case .product:
                    return "1.3.1148"
                case .test:
                    return "1.3.1145"
                case .uat:
                    return "1.3.1148"
                }
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
        return appData.assetInfo[self]?.symbol.filterOnlySystemPrefix ?? self
    }
    
    var precision: Int {
        return appData.assetInfo[self]?.precision ?? 0
    }
    
    var assetID: String {
        return appData.assetNameToIds.value[self] ?? self
    }
}
