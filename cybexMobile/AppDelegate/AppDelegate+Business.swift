//
//  AppDelegate+Configration.swift
//  cybexMobile
//
//  Created by koofrank on 2018/12/11.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import Reachability
import RxSwift
import SwiftyJSON

extension AppDelegate {
    func requestSetting() {
        monitorNetworkOfSetting()

        AppConfiguration.shared.nodes.asObservable().skip(1).subscribe(onNext: { (json) in
            if let node = json?["nodes"].object, let mdp = json?["mdp"].object, let limitOrder = json?["limit_order"].object {
                if AppEnv.current == .product {
                    let nodes = [node].flatMapped(with: String.self)
                    CybexWebSocketService.Config.productURL = nodes.map({ URL(string: $0)! })

                    let mdps = [mdp].flatMapped(with: String.self)
                    MDPWebSocketService.Config.productURL = mdps.map({ URL(string: $0)! })

                    let limitOrders = [limitOrder].flatMapped(with: String.self)
                    OCOWebSocketService.Config.productURL = limitOrders.map({ URL(string: $0)! })

                    let connected = CybexWebSocketService.shared.checkNetworConnected()
                    if !connected {
                        CybexWebSocketService.shared.connect()
                    }
                }
            }
        }).disposed(by: disposeBag)

        AppConfiguration.shared.enableSetting.asObservable().skip(1).subscribe(onNext: { (appSetting) in
            AssetConfiguration.shared.fetchWhiteListAssets()
        }).disposed(by: disposeBag)

        AssetConfiguration.shared.whiteListOfIds.asObservable().skip(1).subscribe(onNext: { (_) in
            MarketConfiguration.shared.fetchMarketPairList()
        }).disposed(by: disposeBag)

        MarketConfiguration.shared.marketPairs.asObservable().skip(1).subscribe(onNext: { (_) in
            AppConfiguration.shared.startFetchOuterPrice()
        }).disposed(by: disposeBag)

        CybexWebSocketService.shared.canSendMessageReactive.skip(1).asObservable().subscribe(onNext: { (_) in
            if CybexConfiguration.shared.chainID.value.isEmpty {
                CybexConfiguration.shared.getChainId()
            }
        }).disposed(by: disposeBag)

        Observable.combineLatest(
            MarketConfiguration.shared.marketPairs.skip(1).asObservable(),
            CybexWebSocketService.shared.canSendMessageReactive.skip(1).asObservable()
            ).subscribe(onNext: { (pairs, canSend) in

                if !pairs.isEmpty, canSend {
                    appCoodinator.getLatestData()
                }
            }).disposed(by: disposeBag)

        appData.assetNameToIds.skip(1).asObservable().subscribe(onNext: { (_) in
            TradeConfiguration.shared.fetchPairPrecision()
        }).disposed(by: disposeBag)
    }

    func monitorNetworkOfSetting() {
        //第一次会直接走回调
        if reachability.connection == .none {
            NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { (note) in
                guard let reachability = note.object as? Reachability else {
                    return
                }

                switch reachability.connection {
                case .wifi, .cellular:
                    self.checkSetting()
                case .none:

                    break
                }

            }
        }

        #if targetEnvironment(simulator) //模拟器第一次收不到 NetWorkChanged 通知
            self.checkSetting()
        #endif
        NotificationCenter.default.addObserver(forName: .NetWorkChanged, object: nil, queue: nil) { (note) in
            self.checkSetting()
        }
    }

    func checkSetting() {
        if AppConfiguration.shared.nodes.value == nil {
            AppConfiguration.shared.fetchNodes()
        }

        if AppConfiguration.shared.enableSetting.value != nil,
            AssetConfiguration.shared.whiteListOfIds.value.isEmpty {
            AssetConfiguration.shared.fetchWhiteListAssets()
        }

        if AppConfiguration.shared.enableSetting.value == nil {
            AppConfiguration.shared.fetchAppEnableSettingRequest()
        }

        if MarketConfiguration.shared.importMarketLists.value.isEmpty {
            MarketConfiguration.shared.fetchTopStickMarkets()
        }
        
        if AssetConfiguration.shared.quoteToProjectNames.value.isEmpty {
            AssetConfiguration.shared.fetchQuoteToProjectNames()
        }
    }
}
