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

extension AppDelegate {
    func requestSetting() {
        monitorNetworkOfSetting()

        AssetConfiguration.shared.whiteListOfIds.asObservable().skip(1).subscribe(onNext: { (_) in
            MarketConfiguration.shared.fetchMarketPairList()
        }).disposed(by: disposeBag)

        MarketConfiguration.shared.marketPairs.asObservable().skip(1).subscribe(onNext: { (_) in
            AppConfiguration.shared.startFetchOuterPrice()
        }).disposed(by: disposeBag)

        Observable.combineLatest(
            MarketConfiguration.shared.marketPairs.skip(1).asObservable(),
            CybexWebSocketService.shared.canSendMessageReactive.skip(1).asObservable()
            ).subscribe(onNext: { (pairs, canSend) in
                if !pairs.isEmpty, canSend {
                    appCoodinator.getLatestData()
                }
            }).disposed(by: disposeBag)
    }

    func monitorNetworkOfSetting() {
        //第一次会直接走回调
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

        NotificationCenter.default.addObserver(forName: .NetWorkChanged, object: nil, queue: nil) { (note) in
            self.checkSetting()
        }
    }

    func checkSetting() {
        if AppConfiguration.shared.enableSetting.value == nil {
            AppConfiguration.shared.fetchAppEnableSettingRequest()
        }
        if AssetConfiguration.shared.whiteListOfIds.value.isEmpty {
            AssetConfiguration.shared.fetchWhiteListAssets()
        }

        if MarketConfiguration.shared.importMarketLists.value.isEmpty {
            MarketConfiguration.shared.fetchTopStickMarkets()
        }
    }
}
