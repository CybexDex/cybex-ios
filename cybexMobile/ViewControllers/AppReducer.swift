//
//  AppReducer.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ReSwift
import RxCocoa
import SwifterSwift

public class BlockSubscriber<S>: StoreSubscriber {
  public typealias StoreSubscriberStateType = S
  private let block: (S) -> Void
  
  public init(block: @escaping (S) -> Void) {
    self.block = block
  }
  
  public func newState(state: S) {
    self.block(state)
  }
}

let TrackingMiddleware: Middleware<Any> = { dispatch, getState in
  return { next in
    return { action in
      
      if let action = action as? StartLoading {
       
//        action.vc?.startLoading()
      }
      else if let action = action as? EndLoading {
//        action.vc?.endLoading()
        
      }
      else if let action = action as? RefreshState {
        _ = action.vc?.perform(action.sel)
      }
      
      return next(action)
    }
  }
}


func loadingReducer(_ state: Bool?, action: Action) -> Bool {
  var state = state ?? false
  
  switch action {
  case _ as StartLoading:
    state = true
  case _ as EndLoading:
    state = false
  default:
    break
  }
  
  return state
}

func errorMessageReducer(_ state: String?, action: Action) -> String {
  var state = state ?? ""
  
  switch action {
  case let action as NetworkErrorMessage:
    state = action.errorMessage
  case _ as CleanErrorMessage:
    state = ""
  default:
    break
  }
  
  return state
}

func pageReducer(_ state: Int?, action: Action) -> Int {
  var state = state ?? 1
  
  switch action {
  case _ as NextPage:
    state = state + 1
  case _ as ResetPage:
    state = 1
  default:
    break
  }
  
  return state
}


func AppReducer(action:Action, state:AppState?) -> AppState {
  return AppState(property: AppPropertyReducer(state?.property, action: action))
}


let s = DispatchSemaphore(value: 1)

func AppPropertyReducer(_ state: AppPropertyState?, action: Action) -> AppPropertyState {
  var state = state ?? AppPropertyState()

  var ids = state.subscribeIds ?? [:]
  var refreshTimes = state.pairsRefreshTimes ?? [:]
  var klineDatas = state.detailData ?? [:]
  
  switch action {
  case let action as MarketsFetched:
    async {
      if s.wait(timeout: .distantFuture) == .success {

      let (matrixs, data) = applyMarketsToState(state, action: action)
       
      main {
        state.matrixs.accept(matrixs)
        state.data.accept(data)
        refreshTimes[Pair(base:action.pair.firstAssetId, quote:action.pair.secondAssetId)] = Date().timeIntervalSince1970
        state.pairsRefreshTimes = refreshTimes
        s.signal()
      }
      }
    }

  case let action as SubscribeSuccess:
    ids[action.pair] = action.id
    refreshTimes[action.pair] = Date().timeIntervalSince1970
    state.subscribeIds = ids
    state.pairsRefreshTimes = refreshTimes
    
  case let action as AssetInfoAction:
    state.assetInfo[action.assetID] = action.info
  case let action as kLineFetched:
    
    if klineDatas.has(key: action.pair) {
      var klineData = klineDatas[action.pair]!
      klineData[action.stick] = action.assets
      klineDatas[action.pair] = klineData
    }
    else {
      klineDatas[action.pair] = [action.stick: action.assets]
    }
    state.detailData = klineDatas
  case let action as FecthEthToRmbPriceAction:
    if action.price.count > 0 {
      for rmbPrices in action.price{
        if rmbPrices.name == "ETH"{
          if rmbPrices.rmb_price != "" && rmbPrices.rmb_price != "0"{
            state.eth_rmb_price = rmbPrices.rmb_price.toDouble()!
          }
        }
      }
    }
    state.rmb_prices = action.price
  
  default:
    break
  }
  
  return state
}

func applyMarketsToState(_ state: AppPropertyState, action:MarketsFetched) -> (matrix:[Pair:BucketMatrix], bucket:[HomeBucket]) {
  var data = state.data.value
  var matrixs = state.matrixs.value
  
  guard let base_info = state.assetInfo[action.pair.firstAssetId], let quote_info = state.assetInfo[action.pair.secondAssetId] else {
    return (matrixs, data)
    
  }

  var homeBucket = HomeBucket(base: action.pair.firstAssetId, quote: action.pair.secondAssetId, bucket: [], base_info: base_info, quote_info: quote_info)
  if action.assets.count != 0  {
    homeBucket.bucket = action.assets
  }
  
  let (contain, index) = data.containHashable(homeBucket)
  
  let matrix = BucketMatrix(homeBucket)

  if !contain {
    data.append(homeBucket)
  }
  else {
    data[index] = homeBucket
  }
  matrixs[Pair(base:homeBucket.base, quote:homeBucket.quote)] = matrix

  
  if data.count > 1 {
    
    let sortedData = data.sorted { (last, cur) -> Bool in
      if last.bucket.count == 0 && cur.bucket.count != 0 {
        return false
      }
      else if last.bucket.count != 0 && cur.bucket.count == 0 {
        return true
      }
      else if last.bucket.count == 0 && cur.bucket.count == 0 {
        return false
      }
      
      let last_matrix = matrixs.values.filter({ last.base == $0.base && last.quote == $0.quote }).first!
      let cur_matrix = matrixs.values.filter({ cur.base == $0.base && cur.quote == $0.quote }).first!

      return last_matrix.base_volume_origin > cur_matrix.base_volume_origin
    }
    
    return (matrixs, sortedData)
  }
  else {
    
    return (matrixs,data)
  }

}
