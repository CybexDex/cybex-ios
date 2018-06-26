//
//  BusinessCoordinator.swift
//  cybexMobile
//
//  Created DKM on 2018/6/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import ReSwift

protocol BusinessCoordinatorProtocol {
}

protocol BusinessStateManagerProtocol {
    var state: BusinessState { get }
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<BusinessState>) -> Subscription<SelectedState>)?
    ) where S.StoreSubscriberStateType == SelectedState
  
  func switchPrice(_ price:String)
  func adjustPrice(_ plus:Bool, precision:Int)

  func changePercent(_ percent:Double, isBuy:Bool, assetID:String, precision:Int)
  func getBalance(_ assetID:String)

  func getFee(_ focus_asset_id:String)
  func resetState()
}

class BusinessCoordinator: AccountRootCoordinator {
    
    lazy var creator = BusinessPropertyActionCreate()
    
    var store = Store<BusinessState>(
        reducer: BusinessReducer,
        state: nil,
        middleware:[TrackingMiddleware]
    )
}

extension BusinessCoordinator: BusinessCoordinatorProtocol {
    
}

extension BusinessCoordinator: BusinessStateManagerProtocol {
    var state: BusinessState {
        return store.state
    }
    
    func subscribe<SelectedState, S: StoreSubscriber>(
        _ subscriber: S, transform: ((Subscription<BusinessState>) -> Subscription<SelectedState>)?
        ) where S.StoreSubscriberStateType == SelectedState {
        store.subscribe(subscriber, transform: transform)
    }
  
  func switchPrice(_ price:String) {
    self.store.dispatch(changePriceAction(price: price))
  }
  
  func adjustPrice(_ plus:Bool, precision:Int) {
    self.store.dispatch(adjustPriceAction(gap: plus ? 1.0 / pow(10, precision.double) : -1.0 / pow(10, precision.double), precision:precision))
  }
  
  func getFee(_ focus_asset_id:String) {
    if let str = BitShareCoordinator.getLimitOrderOperation(0, expiration: 0, asset_id: 0, amount: 0, receive_asset_id: 0, receive_amount: 0, fee_id: 0, fee_amount: 0) {
      calculateFee(str, focus_asset_id: focus_asset_id) { (success, amount, assetID) in
        self.store.dispatch(feeFetchedAction(success: success, amount: amount, assetID: assetID))
      }
    }
  }
  
  func changePercent(_ percent:Double, isBuy:Bool, assetID:String, precision:Int) {
    let fee_amount = self.state.property.fee_amount.value
    let balance = self.state.property.balance.value
    let fee_id = self.state.property.feeID.value

    if let price = self.state.property.price.value.toDouble(), price != 0, fee_amount != 0, balance != 0 {
      var amount:Double = 0

      if isBuy {
        if fee_id == assetID {
          amount = (balance - fee_amount) * percent / price
        }
        else {
          amount = balance * percent / price
        }
      }
      else {
        if fee_id == assetID {
          amount = balance * percent
        }
        else {
          amount = (balance - fee_amount) * percent
        }
      }
      
      self.store.dispatch(switchPercentAction(amount: amount, precision: precision))
    }
  }
  
  func getBalance(_ assetID:String){
    if let balances = UserManager.shared.balances.value?.filter({ (balance) -> Bool in
      return balance.asset_type.filterJade == assetID
    }).first {
      let amount = getRealAmount(balances.asset_type, amount: balances.balance)
      self.store.dispatch(BalanceFetchedAction(amount:amount))
    }
  }
  
  func resetState() {
    self.store.dispatch(resetTrade())
  }
}
