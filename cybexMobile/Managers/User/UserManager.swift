//
//  UserManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON
import CryptoSwift
import KeychainAccess
import FCUUID
import RxCocoa
import RxSwift

extension UserManager {
  func login(_ username:String, password:String) {
    generateKeys(username, password: password)
  }
  
  func validateLogin(_ username:String, password:String) {
    let request = GetFullAccountsRequest(name: username) { result in
      if let result = result as? FullAccount {
        let member = result.account?.superMember
        
      }
    }
    
    WebsocketService.shared.send(request: request)
  }
  
  func register() {
    
  }
  
  func fetchAccountInfo(){
    guard let userName = name else {
      return
    }
    
    let request = GetFullAccountsRequest(name: userName) { response in
      if let data = response as? FullAccount{
      
        if data.account == nil{
          self.isLoginIn = false
        }else{
          self.isLoginIn = true
        }
        self.account.accept(data.account)
        self.balances.accept(data.balances)
        self.limitOrder.accept(data.limitOrder)
      
      }
    }
    WebsocketService.shared.send(request: request)
  }

}

class UserManager {
  static let shared = UserManager()
  var disposeBag = DisposeBag()

  var isLoginIn : Bool = false
  var name : String?
  var keys:AccountKeys?
  var avatarString:String?
  var account:BehaviorRelay<Account?> = BehaviorRelay(value: nil)
  var balances:BehaviorRelay<[Balance]?> = BehaviorRelay(value: nil)
  var limitOrder:BehaviorRelay<[LimitOrder]?> = BehaviorRelay(value:nil)
  
  var balance : Double{
    
    var balance_values:Double = 0
    if let balances = balances.value {
      for balance_value in balances{
        balance_values += getRealAmount(balance_value.asset_type,amount: balance_value.balance) * changeToETHAndCYB(balance_value.asset_type).cyb.toDouble()!
      }
    }
    if let limitOrder = limitOrder.value{
      for limitOrder_value in limitOrder{
        let (base,quote) = calculateAssetRelation(assetID_A_name: limitOrder_value.sellPrice.base.assetID, assetID_B_name: limitOrder_value.sellPrice.quote.assetID)
        let isBuy = base == limitOrder_value.sellPrice.base.assetID
        if isBuy {
          balance_values += getRealAmount(base, amount: limitOrder_value.sellPrice.base.amount)
        }else{
          balance_values += getRealAmount(quote, amount: limitOrder_value.sellPrice.quote.amount)
        }
      }
    }
    return balance_values
  }
  
  private init() {
    app_data.data.asObservable().distinctUntilChanged()
      .filter({$0.count == AssetConfiguration.shared.asset_ids.count})
      .subscribe(onNext: { (s) in
        DispatchQueue.main.async {
          if !UserManager.shared.isLoginIn && AssetConfiguration.shared.asset_ids.count > 0 {
            UserManager.shared.fetchAccountInfo()
          }

        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  private func generateKeys(_ username:String, password:String) {
    let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
    
    name = username
    saveKey(keysString)
    if let keys = AccountKeys(JSONString: keysString) {
      self.keys = keys
      
      self.avatarString = username.sha256()
      
    }
    
  }
  
  private func saveKey(_ key:String) {
    let uuid = UIDevice.current.uuid()!
    
    let keychain = Keychain(service: "com.nbltrust.cybex")
    keychain[uuid] = key
  }
  
}


