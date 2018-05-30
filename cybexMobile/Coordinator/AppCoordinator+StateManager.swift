//
//  AppCoordinator+StateManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/26.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import AwaitKit
import Repeat

extension AppCoordinator: AppStateManagerProtocol {
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<AppState>) -> Subscription<SelectedState>)?
  ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }

  func fetchData(_ params: AssetPairQueryParams, sub: Bool = true) {
    store.dispatch(creator.fetchMarket(with: sub, params: params, callback: { [weak self] (assets) in
      guard let `self` = self else { return }

      self.store.dispatch(MarketsFetched(pair: params, assets: assets))
    }))
  }

  func fetchKline(_ params: AssetPairQueryParams, gap: candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
    store.dispatch(creator.fetchMarket(with: false, params: params, callback: { [weak self] (assets) in
      guard let `self` = self else { return }

      self.store.dispatch(kLineFetched(pair: Pair(base: params.firstAssetId, quote: params.secondAssetId), stick: gap, assets: assets))
      if let vc = vc, let sel = selector {
        self.store.dispatch(RefreshState(sel: sel, vc: vc))
      }
    }))
  }

  func fetchAsset() {
    guard AssetConfiguration.shared.asset_ids.count > 0 else { return }

    let request = GetAssetRequest(ids: AssetConfiguration.shared.unique_ids) { response in
      if let assetinfo = response as? [AssetInfo] {
        for info in assetinfo {
          self.store.dispatch(AssetInfoAction(assetID: info.id, info: info))
        }
      }
      
      
    }
    WebsocketService.shared.send(request: request)
  }
  
  func fetchEthToRmbPrice(){
    async {
      let value = try! await(SimpleHTTPService.requestETHPrice())
      if value == 0 {
        return
      }
      main { [weak self] in
        self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
      }
    }
    
    self.timer = Repeater.every(.seconds(3)) {[weak self] timer in
      let value = try! await(SimpleHTTPService.requestETHPrice())
      if value == 0 {
        return
      }
      DispatchQueue.main.async { [weak self] in
        self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
      }
    }
    
    timer?.start()

  }
}

extension AppCoordinator {
  func request24hMarkets(_ pairs: [Pair], sub: Bool = true) {
    let now = Date()
    let curTime = now.timeIntervalSince1970

    var start = now.addingTimeInterval(-3600 * 24)

    let timePassed = (-start.minute * 60 - start.second).double
    start = start.addingTimeInterval(timePassed)


    for pair in pairs {
      if let refreshTimes = app_data.pairsRefreshTimes, let oldTime = refreshTimes[pair] {
        if curTime - oldTime < 5 {
          continue
        }

      }

      AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub)
    }

  }

  func requestKlineDetailData(pair: Pair, gap: candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
    let now = Date()
    let start = now.addingTimeInterval(-gap.rawValue * 199)

    AppConfiguration.shared.appCoordinator.fetchKline(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: gap.rawValue.int, startTime: start, endTime: now), gap: gap, vc: vc, selector: selector)
  }

  func getLatestData() {
    if AssetConfiguration.shared.asset_ids.isEmpty {
      var pairs:[Pair] = []
      async {
        AssetConfiguration.market_base_assets.forEach { (base) in
          let pair = try! await(SimpleHTTPService.requestMarketList(base:base))
          pairs += pair
        }
        
        main {
          AssetConfiguration.shared.asset_ids = pairs
          self.fetchAsset()
          self.request24hMarkets(AssetConfiguration.shared.asset_ids)
        }
      }
      

    }
    else {
      if app_data.assetInfo.count != AssetConfiguration.shared.asset_ids.count {
        fetchAsset()
      }
      request24hMarkets(AssetConfiguration.shared.asset_ids)
    }

  }
}



