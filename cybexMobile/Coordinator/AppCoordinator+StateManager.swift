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
import SwifterSwift

extension AppCoordinator: AppStateManagerProtocol {
  func subscribe<SelectedState, S: StoreSubscriber>(
    _ subscriber: S, transform: ((Subscription<AppState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState {
    store.subscribe(subscriber, transform: transform)
  }
  
  func fetchData(_ params: AssetPairQueryParams, sub: Bool = true,callback:@escaping ()->()) {
    store.dispatch(creator.fetchMarket(with: sub, params: params, callback: { [weak self] (assets) in
      guard let `self` = self else { return }
      callback()
      self.store.dispatch(MarketsFetched(pair: params, assets: assets))
    }))
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
  
  func fetchAsset(_ callback:@escaping (()->Void)) {
    async {
      let data = try! await(SimpleHTTPService.fetchIdsInfo())
      
      main {
        AssetConfiguration.shared.unique_ids = data
        let request = GetObjectsRequest(ids: data) { response in
          if let assetinfo = response as? [AssetInfo] {
            for info in assetinfo {
              self.store.dispatch(AssetInfoAction(assetID: info.id, info: info))
            }
            callback()
            
          }
        }
        WebsocketService.shared.send(request: request)
      }
      
    }
    
  }
  
  func fetchEthToRmbPrice(){
    async {
      let value = try! await(SimpleHTTPService.requestETHPrice())
      if value.count == 0 {
        return
      }
      main { [weak self] in
        self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
      }
    }
    
    self.timer = Repeater.every(.seconds(3)) {[weak self] timer in
      let value = try! await(SimpleHTTPService.requestETHPrice())
      if value.count == 0 {
        return
      }
      main { [weak self] in
        self?.store.dispatch(FecthEthToRmbPriceAction(price: value))
      }
    }
    
    timer?.start()
    
  }
}

extension AppCoordinator {
  func request24hMarkets(_ pairs: [Pair], sub: Bool = true ,totalTime:Double = 3,splits:Int = 3) {
    let now = Date()
    let curTime = now.timeIntervalSince1970
    
    var start = now.addingTimeInterval(-3600 * 24)
    
    let timePassed = (-start.minute * 60 - start.second).double
    start = start.addingTimeInterval(timePassed)
    var filterPairs = pairs.filter { (pair) -> Bool in
      if let refreshTimes = app_data.pairsRefreshTimes, let oldTime = refreshTimes[pair] {
        return curTime - oldTime >= 5
      }
      return true
    }
    //    log.warning("firstFetchPairsCount \(firstFetchPairsCount)")
    //    log.warning("secondFetchPairsCount \(secondFetchPairsCount)")
    //    log.warning("thirdFetchPairsCount \(thirdFetchPairsCount)")
    
    if self.firstFetchPairsCount != 0 || self.secondFetchPairsCount != 0 || self.thirdFetchPairsCount != 0 {
      return
    }
    
    // 筛选后的pairs
    let length : Int = filterPairs.count / 3
    if length > 1,!sub {
      self.firstFetchPairsCount = length
      self.secondFetchPairsCount = length + 1
      self.thirdFetchPairsCount = filterPairs.count - 2 * length - 1
      for index in 0...length - 1 {
        let pair = filterPairs[index]
        //        log.warning("first")
        AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub) {
          //          log.warning("first response")
          self.firstFetchPairsCount -= 1
        }
      }
      SwifterSwift.delay(milliseconds: 1000) {
        for index in length...2*length {
          
          let pair = filterPairs[index]
          //          log.warning("second")
          AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub) {
            //            log.warning("second response")
            
            self.secondFetchPairsCount -= 1
          }
        }
      }
      SwifterSwift.delay(milliseconds: 2000) {
        for index in 2*length+1...filterPairs.count - 1 {
          
          let pair = filterPairs[index]
          //          log.warning("third")
          
          AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub) {
            //            log.warning("third response")
            self.thirdFetchPairsCount -= 1
          }
        }
      }
    }else {
      for pair in filterPairs {
        AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub)
      }
    }
    
    
    //    for pair in filterPairs {
    //      if let refreshTimes = app_data.pairsRefreshTimes, let oldTime = refreshTimes[pair] {
    //        if curTime - oldTime < 5 {
    //          continue
    //        }
    //
    //      }
    //
    //      AppConfiguration.shared.appCoordinator.fetchData(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: 60 * 60, startTime: start, endTime: now), sub: sub)
    //    }
    
  }
  
  
  
  func repeatFetchPairInfo(){
    
    if self.fetchPariTimer != nil ,!(self.fetchPariTimer?.state.isRunning)!{
      self.fetchPariTimer?.pause()
      self.fetchPariTimer = nil
    }
    self.fetchPariTimer = Repeater.every(.seconds(3), { [weak self](timer) in
      guard let `self` = self else {return}
      let status = RealReachability.sharedInstance().currentReachabilityStatus()
      if status == .RealStatusNotReachable || status  == .RealStatusUnknown {
        timer.pause()
        
        return
      }
      self.request24hMarkets(AssetConfiguration.shared.asset_ids, sub: false)
    })
  }
  
  
  
  func requestKlineDetailData(pair: Pair, gap: candlesticks, vc: BaseViewController? = nil, selector: Selector?) {
    let now = Date()
    let start = now.addingTimeInterval(-gap.rawValue * 199)
    
    AppConfiguration.shared.appCoordinator.fetchKline(AssetPairQueryParams(firstAssetId: pair.base, secondAssetId: pair.quote, timeGap: gap.rawValue.int, startTime: start, endTime: now), gap: gap, vc: vc, selector: selector)
  }
  
  func getLatestData() {
    if AssetConfiguration.shared.asset_ids.isEmpty {
      fetchAsset {
        var pairs:[Pair] = []
        var count = 0
        for base in AssetConfiguration.market_base_assets {
          SimpleHTTPService.requestMarketList(base:base).done({ (pair) in
            log.error("requestMarketList base \(base)  pairs  \(pair.count)")
            let piece_pair = pair.filter({ (p) -> Bool in
              return AssetConfiguration.shared.unique_ids.contains([p.base, p.quote])
            })
            count += 1
            
            pairs += piece_pair
            if count == AssetConfiguration.market_base_assets.count {
              AssetConfiguration.shared.asset_ids = pairs
              self.request24hMarkets(AssetConfiguration.shared.asset_ids)
            }
          }).cauterize()
        }
      }
      
    }
    else {
      if app_data.assetInfo.count != AssetConfiguration.shared.unique_ids.count {
        fetchAsset {
          self.request24hMarkets(AssetConfiguration.shared.asset_ids)
        }
      }
      request24hMarkets(AssetConfiguration.shared.asset_ids)
    }
    
  }
}



