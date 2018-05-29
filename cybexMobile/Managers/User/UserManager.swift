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
import PromiseKit
import AwaitKit
import Guitar

extension UserManager {
  func login(_ username:String, password:String, completion:@escaping (Bool)->()) {
    let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
    if let keys = AccountKeys(JSONString: keysString), let active_key = keys.active_key {
      let public_key = active_key.public_key
      var canLoginIn = false
      
      let request = GetFullAccountsRequest(name: username) { response in
        if let data = response as? FullAccount, let account = data.account {
          
          let active_auths = account.active_auths
          let owner_auths = account.owner_auths
          
          for auth in active_auths {
            if let auth = auth as? [Any], let key = auth[0] as? String {
              if key == public_key {
                canLoginIn = true
                break
              }
            }
          }
          
          for auth in owner_auths {
            if let auth = auth as? [Any], let key = auth[0] as? String {
              if key == public_key {
                canLoginIn = true
                break
              }
            }
          }
          
          if canLoginIn {
            self.name = username
            self.avatarString = username.sha256()
            self.keys = keys
            self.saveKey(keysString, name:username)
            
            self.account.accept(data.account)
            
            if let balances = data.balances{
              self.balances.accept(balances.filter({ (balance) -> Bool in
                return getRealAmount(balance.asset_type, amount: balance.balance) != 0
              }))
            }else{
              self.balances.accept(data.balances)
            }
            self.limitOrder.accept(data.limitOrder)
            
            completion(true)
            return
          }
        }
        
        completion(false)
      }
      WebsocketService.shared.send(request: request)
      
    }
  }
  
  func validateUserName(_ username:String) -> (Bool, String) {
    let letterBegin = Guitar(pattern: "^([a-zA-Z])")
    if !letterBegin.test(string: username) {
      return (false, R.string.localizable.accountValidateError2.key.localized())
    }
    
    let legal = Guitar(pattern: "([^a-zA-z0-9\\-])")
    if legal.test(string: username) {
      return (false, R.string.localizable.accountValidateError6.key.localized())
    }
    
    if username.count > 63 || username.count < 3 {
      return (false, R.string.localizable.accountValidateError3.key.localized())
    }
    
    let containOther = Guitar(pattern: "[0-9+|\\-+]")
    let continuousDashes = Guitar(pattern: "(\\-\\-)")
    let dashEnd = Guitar(pattern: "(\\-)$")
    
    
    if !containOther.test(string: username) {
      return (false, R.string.localizable.accountValidateError4.key.localized())
    }
    
    if continuousDashes.test(string: username) {
      return (false, R.string.localizable.accountValidateError5.key.localized())
    }
    
    if dashEnd.test(string: username) {
      return (false, R.string.localizable.accountValidateError7.key.localized())
    }
    
    
    return (true , "")
  }
  
  func checkUserName(_ username:String) -> Promise<Bool> {
    return async {
      let exist = try! await(UserManager.shared.checkUserNameExist(username))
      
      return exist
    }
  }
  
  func register(_ pinID:String, captcha:String, username:String, password:String) -> Promise<(Bool,Int)> {
    return async {
      let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
      
      if let keys = AccountKeys(JSONString: keysString), let active_key = keys.active_key, let owner_key = keys.owner_key, let memo_key = keys.memo_key {
        let params = ["cap":["id":pinID, "captcha":captcha], "account":["name":username, "owner_key":owner_key.public_key, "active_key":active_key.public_key,"memo_key":memo_key.public_key, "refcode":"", "referrer":""]]
        
        let data = try! await(SimpleHTTPService.requestRegister(params))
        if data.0 {
          self.name = username
          self.avatarString = username.sha256()
          self.keys = keys
          self.saveKey(keysString, name:username)
          self.fetchAccountInfo()
        }
        return data
        
      }
      return (false, 0)
    }
  }
  
  func logout() {
    let uuid = UIDevice.current.uuid()!
    let keychain = Keychain(service: "com.nbltrust.cybex")
    try? keychain.remove(uuid)
    
    UserDefaults.standard.remove("com.nbltrust.cybex.username")
    self.name = nil
    self.avatarString = nil
    self.keys = nil
    self.account.accept(nil)
    self.balances.accept(nil)
    self.limitOrder.accept(nil)
    
  }
  
  func fetchAccountInfo(){
    if !isLoginIn {
      return
    }
    
    if let username = self.name {
      let request = GetFullAccountsRequest(name: username) { response in
        if let data = response as? FullAccount{
          
          self.account.accept(data.account)
          
          if let balances = data.balances{
            self.balances.accept(balances.filter({ (balance) -> Bool in
                return getRealAmount(balance.asset_type, amount: balance.balance) != 0
            }))
          
          }else{
            self.balances.accept(data.balances)
          }
          self.limitOrder.accept(data.limitOrder)
        }
      }
      WebsocketService.shared.send(request: request)
    }
  }
  
  private func checkUserNameExist(_ name:String) -> Promise<Bool> {
    let (promise,seal) = Promise<Bool>.pending()
    
    let request = GetAccountByNameRequest(name: name) { response in
      WebsocketService.shared.callbackQueue = DispatchQueue.main
      if let result = response as? Bool {
        seal.fulfill(result)
      }
      
    }
    
    WebsocketService.shared.callbackQueue = Await.Queue.await
    WebsocketService.shared.send(request: request)
    
    return promise
  }
  
}

class UserManager {
  static let shared = UserManager()
  var disposeBag = DisposeBag()
  
  var isLoginIn : Bool {
    let uuid = UIDevice.current.uuid()!
    let keychain = Keychain(service: "com.nbltrust.cybex")
    if let keysString = keychain[uuid], let keys = AccountKeys(JSONString: keysString), let name = UserDefaults.standard.object(forKey: "com.nbltrust.cybex.username") as? String {
      self.name = name
      self.avatarString = name.sha256()
      self.keys = keys
      
      return true
    }
    
    return false
  }
  
  var name : String?
  var keys:AccountKeys?
  var avatarString:String?
  var account:BehaviorRelay<Account?> = BehaviorRelay(value: nil)
  var balances:BehaviorRelay<[Balance]?> = BehaviorRelay(value: nil)
  var limitOrder:BehaviorRelay<[LimitOrder]?> = BehaviorRelay(value:nil)
  
  var limitOrderValue:Double = 0
  var limitOrder_buy_value: Double = 0
  
  var balance : Double {
    
    var balance_values:Double = 0
    var _limitOrderValue:Double = 0
    var _limitOrder_buy_value:Double = 0
    
    if let balances = balances.value {
      for balance_value in balances{
        if let eth_cyb = changeToETHAndCYB(balance_value.asset_type).cyb.toDouble() {
          balance_values += getRealAmount(balance_value.asset_type,amount: balance_value.balance) * eth_cyb
        }
      }
    }
    
    if let limitOrder = limitOrder.value{
      for limitOrder_value in limitOrder{
        let assetA_info = app_data.assetInfo[limitOrder_value.sellPrice.base.assetID]
        let assetB_info = app_data.assetInfo[limitOrder_value.sellPrice.quote.assetID]
        
        let (base,_) = calculateAssetRelation(assetID_A_name: (assetA_info != nil) ? assetA_info!.symbol.filterJade : "", assetID_B_name: (assetB_info != nil) ? assetB_info!.symbol.filterJade : "")
        let isBuy = base == ((assetA_info != nil) ? assetA_info!.symbol.filterJade : "")
        
        if isBuy {
          if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
            let buy_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale) * eth_cyb
            _limitOrderValue += buy_value
            _limitOrder_buy_value += buy_value
            balance_values += buy_value
          }
        }
        else{
          if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
            let sell_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale) * eth_cyb
            _limitOrderValue += sell_value
            balance_values += sell_value
          }
        }
      }
    }
    
    limitOrderValue = _limitOrderValue
    limitOrder_buy_value = _limitOrder_buy_value
    
    return balance_values
  }
  
  private init() {
    app_data.data.asObservable().distinctUntilChanged()
      .filter({$0.count == AssetConfiguration.shared.asset_ids.count})
      .subscribe(onNext: { (s) in
        DispatchQueue.main.async {
          if UserManager.shared.isLoginIn && AssetConfiguration.shared.asset_ids.count > 0 {
//            UserManager.shared.fetchAccountInfo()
          }
          
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
  }
  
  
  private func saveKey(_ key:String, name:String) {
    let uuid = UIDevice.current.uuid()!
    
    let keychain = Keychain(service: "com.nbltrust.cybex")
    keychain[uuid] = key
    
    UserDefaults.standard.set(name, forKey: "com.nbltrust.cybex.username")
    
  }
  
  
  func getPortfolioDatas() -> [PortfolioData]{
    var datas = [PortfolioData]()
    if let balances = self.balances.value{
      for balance in balances{
        datas.append(PortfolioData.init(balance: balance)!)
      }
    }
    return datas
  }
  
  
}


