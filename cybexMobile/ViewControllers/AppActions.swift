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

struct AppState:StateType {
  var property: AppPropertyState
}
struct AppPropertyState {
  var data:BehaviorRelay<[HomeBucket]> = BehaviorRelay(value: [])
  
  var matrixs:BehaviorRelay<[Pair:BucketMatrix]> = BehaviorRelay(value:[:])
  
  var detailData:[Pair:[candlesticks:[Bucket]]]?

  var subscribeIds:[Pair:Int]?
  var pairsRefreshTimes:[Pair:Double]?

  var assetInfo:[String:AssetInfo] = [:]
  
  var rmb_prices : [RMBPrices] = []
  
  var eth_rmb_price : Double  = 0
  
  
  func filterQuoteAsset(_ base:String) -> [HomeBucket] {
    return data.value.filter({ (bucket) -> Bool in
      return bucket.base == base
    })
  }
}

struct HomeBucket:Equatable,Hashable {
  let base:String
  let quote:String
  var bucket:[Bucket]
  let base_info:AssetInfo
  let quote_info:AssetInfo

  public static func == (lhs: HomeBucket, rhs: HomeBucket) -> Bool {
    return lhs.base == rhs.base && lhs.quote == rhs.quote && lhs.bucket == rhs.bucket && lhs.base_info == rhs.base_info && lhs.quote_info == rhs.quote_info
  }
  
  var hashValue: Int {
    let value = base.hashValue < quote.hashValue ? -1 : 1
    let valueStr = "\(base.hashValue)" + "+" + "\(quote.hashValue)"
    return value * valueStr.hashValue
  }
}


struct Pair:Hashable {
  let base:String
  let quote:String
}

class LoadingActionCreator {
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
  let errorMessage:String
}
struct CleanErrorMessage: Action {}

struct NextPage: Action {}

struct ResetPage: Action {}



struct MarketsFetched:Action {
  let pair:AssetPairQueryParams
  let assets:[Bucket]
}

struct kLineFetched:Action {
  let pair:Pair
  let stick:candlesticks
  let assets:[Bucket]
}

struct RefreshState:Action {
  let sel:Selector
  let vc:BaseViewController?
}

struct SubscribeSuccess:Action {
  let pair:Pair
  let id:Int
}

struct AssetInfoAction:Action {
  let assetID:String
  let info:AssetInfo
}

struct FecthEthToRmbPriceAction:Action{
  let price : [RMBPrices]
}
struct FecthUSDTToRmbPriceAction:Action{
  let price : Double
}

typealias MarketDataCallback = ([Bucket]) -> Void

class AppPropertyActionCreate: LoadingActionCreator {
  public typealias ActionCreator = (_ state: AppState, _ store: Store<AppState>) -> Action?
  
  public typealias AsyncActionCreator = (
    _ state: AppState,
    _ store: Store <AppState>,
    _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
    ) -> Void
  
  func fetchMarket(with sub:Bool = true, params:AssetPairQueryParams, callback:MarketDataCallback?) -> ActionCreator {
    return { state, store in
      self.fetchingMarketList(params, callback: {[weak self] (res) in
        guard let `self` = self else { return }
        
        if var assets = res as? [Bucket] {
          if assets.count > 0 {
            let asset = assets[0]
            
            if asset.open > params.startTime.timeIntervalSince1970 {
              
              self.cycleFetch(asset, params: params, callback: { (o_asset) in
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
              
            }
            else {
              callback?(assets)
            }
            
          }
          else {
            callback?([])
          }
        }
        else {
          
        }
      })
      
 
      
      if sub {
        let subRequest = SubscribeMarketRequest(ids: [params.firstAssetId, params.secondAssetId]) { response in
          if let id = response as? Int {
            store.dispatch(SubscribeSuccess(pair: Pair(base: params.firstAssetId, quote: params.secondAssetId), id: id))
          }
        }
        WebsocketService.shared.send(request: subRequest)
      }
      
      return nil
      
    }
  }
  
  func fetchingMarketList(_  params:AssetPairQueryParams, callback:CommonAnyCallback?) {
    
    let request = GetMarketHistoryRequest(queryParams: params) { response in
      if let callback = callback {
        callback(response)
      }
    }
    
    WebsocketService.shared.send(request: request)
  }
  
  func cycleFetch(_ asset:Bucket, params:AssetPairQueryParams, callback:CommonAnyCallback?) {
    var re_params = params
    re_params.startTime = params.startTime.addingTimeInterval(-24 * 3600)
    re_params.endTime = params.startTime
    self.fetchingMarketList(re_params, callback: {[weak self] (o_res) in
      guard let `self` = self else { return }
      if let o_assets = o_res as? [Bucket] {
        if o_assets.count > 0, let o_asset = o_assets.last {
          if let callback = callback {
            callback(o_asset)
          }
        }
        else if o_assets.count > 0 {
          self.cycleFetch(asset, params: re_params, callback: callback)
        }
        else {
          if let callback = callback {
            callback(0)
          }
        }
      }
    })
  }
  
}
