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
import Repeat

extension UserManager {

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
  
  func login(_ username:String, password:String, completion:@escaping (Bool)->()) {
    self.unlock(username, password: password) {[weak self] (locked, data) in
      guard let `self` = self else { return }
      if locked {
        self.saveName(username)
        self.avatarString = username.sha256()

        self.name.accept(username)
        self.handlerFullAcount(data!)
      }
      
      completion(locked)
    }
  }
  
  func register(_ pinID:String, captcha:String, username:String, password:String) -> Promise<(Bool,Int)> {
    return async {
      let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
      
      if let keys = AccountKeys(JSONString: keysString), let active_key = keys.active_key, let owner_key = keys.owner_key, let memo_key = keys.memo_key {
        let params = ["cap":["id":pinID, "captcha":captcha], "account":["name":username, "owner_key":owner_key.public_key, "active_key":active_key.public_key,"memo_key":memo_key.public_key, "refcode":"", "referrer":""]]
        
        let data = try! await(SimpleHTTPService.requestRegister(params))
        if data.0 {
          self.saveName(username)
          self.avatarString = username.sha256()

          self.name.accept(username)
          
          self.keys = keys
          self.fetchAccountInfo()
        }
        return data
        
      }
      return (false, 0)
    }
  }
  
  func logout() {
    BitShareCoordinator.cancelUserKey()
    
    UserDefaults.standard.remove("com.nbltrust.cybex.username")
    self.name.accept(nil)
    self.avatarString = nil
    self.keys = nil
    self.account.accept(nil)
    self.balances.accept(nil)
    self.limitOrder.accept(nil)
    self.fillOrder.accept(nil)
  }
  
  func fetchAccountInfo(){
    if !isLoginIn {
      return
    }
    
    if let username = self.name.value {
      let request = GetFullAccountsRequest(name: username) { response in
        if let data = response as? FullAccount{
          if !self.isLoginIn {
            return
          }
          
          self.handlerFullAcount(data)
        }
      }
      WebsocketService.shared.send(request: request)
    }
  }
  
  func fetchHistoryOfOperation() {
    guard let id = self.account.value?.id else {
      return
    }
    
    let request = GetAccountHistoryRequest(accountID: id) { (data) in
      if var fillorders = data as? [FillOrder] {
        if fillorders.count == 0 || !self.isLoginIn {
          self.fillOrder.accept(nil)
          return
        }
        fillorders = fillorders.filter({
          let base_name = app_data.assetInfo[$0.fill_price.base.assetID]
          let quote_name = app_data.assetInfo[$0.fill_price.quote.assetID]
          return base_name != nil && quote_name != nil
        })
        
        var result = [(FillOrder,time:String)]()
        var count = 0
        for fillOrder in fillorders{
          let timeRequest = getBlockRequest(response: { (time) in
            count += 1
            if let time = time as? String, let date = time.dateFromISO8601{
              result.append((fillOrder,time:(date.string(withFormat: "MM/dd HH:mm:ss"))))
            }
            if count == fillorders.count{
              self.fillOrder.accept(result)
            }
          }, block_num: fillOrder.block_num)
          WebsocketService.shared.send(request: timeRequest)
        }
      }
    }
    WebsocketService.shared.send(request: request)
  }
  
  func checkUserName(_ name:String) -> Promise<Bool> {
    let (promise,seal) = Promise<Bool>.pending()
    
    let request = GetAccountByNameRequest(name: name) { response in
      if let result = response as? Bool {
        seal.fulfill(result)
      }
      
    }
    
    WebsocketService.shared.send(request: request)
    
    return promise
  }
  
  func unlock(_ username:String?, password:String, completion:@escaping (Bool, FullAccount?)->()) {
    guard let name = username ?? self.name.value else {
      completion(false, nil)
      return
    }
    
    let keysString = BitShareCoordinator.getUserKeys(name, password: password)!
    if let keys = AccountKeys(JSONString: keysString), let active_key = keys.active_key {
      let public_key = active_key.public_key
      var canLock = false
      
      let request = GetFullAccountsRequest(name: name) { response in
        if let data = response as? FullAccount, let account = data.account {
          let active_auths = account.active_auths
          let owner_auths = account.owner_auths
          
          for auth in active_auths {
            if let auth = auth as? [Any], let key = auth[0] as? String {
              if key == public_key {
                canLock = true
                BitShareCoordinator.resetDefaultPublicKey(key)
                break
              }
            }
          }
          
          for auth in owner_auths {
            if let auth = auth as? [Any], let key = auth[0] as? String {
              if key == public_key {
                canLock = true
                BitShareCoordinator.resetDefaultPublicKey(key)
                break
              }
            }
          }
          
          if canLock {
            self.keys = keys
            
            if let newAccount = data.account {
              if let memoKey = keys.memo_key, let ownKey = keys.owner_key, let activeKey = keys.active_key {
                if [memoKey.public_key, ownKey.public_key, activeKey.public_key].contains(newAccount.memo_key) {
                  self.isWithDraw = true
                }
              }
              if let memoKey = keys.memo_key, let ownKey = keys.owner_key, let activeKey = keys.active_key{
                if let activeKeys = newAccount.active_auths as? [String]{
                  for activekey in activeKeys{
                    if [memoKey.public_key, ownKey.public_key, activeKey.public_key].contains(activekey){
                      self.isTrade = true
                    }
                  }
                }
              }
            }
            
            completion(true, data)
            self.timingLock()
            return
          }
        }
        completion(false, nil)
      }
      WebsocketService.shared.send(request: request, filterRepeat:false)
    }

    else{
      completion(false, nil)
    }
    
  }
  
  func handlerFullAcount(_ data:FullAccount) {
    self.account.accept(data.account)
    
    if let balances = data.balances {
      self.balances.accept(balances.filter({ (balance) -> Bool in
        let name = app_data.assetInfo[balance.asset_type]
        return getRealAmount(balance.asset_type, amount: balance.balance) != 0 &&
          (name != nil) && ((name?.symbol.hasPrefix("JADE"))! ||  name?.symbol == "CYB")
      }))
      
    }else{
      self.balances.accept(data.balances)
    }
    
    if let limitOrders = data.limitOrder {
      self.limitOrder.accept(limitOrders.filter({ (limitOrder) -> Bool in
        let base_name = app_data.assetInfo[limitOrder.sellPrice.base.assetID]
        let quote_name = app_data.assetInfo[limitOrder.sellPrice.quote.assetID]
        let base_bool = base_name != nil && ((base_name?.symbol.hasPrefix("JADE"))! || base_name?.symbol == "CYB")
        let quote_bool = quote_name != nil && ((quote_name?.symbol.hasPrefix("JADE"))! || quote_name?.symbol == "CYB")
        
        return base_bool && quote_bool
      }))
    }else{
      self.limitOrder.accept(data.limitOrder)
    }
  }
  
}

class UserManager {
  static let shared = UserManager()
  var disposeBag = DisposeBag()
  
  var isLoginIn : Bool {
    if let name = UserDefaults.standard.object(forKey: "com.nbltrust.cybex.username") as? String {
      if self.name.value == nil {
        self.name.accept(name)
        self.avatarString = name.sha256()
      }

      return true
    }
    return false
  }
  
  var isLocked:Bool {
    return self.keys == nil
  }
  
  var isWithDraw : Bool = false
  var isTrade : Bool = false
  var name : BehaviorRelay<String?> = BehaviorRelay(value: nil)
  var keys:AccountKeys?
  var avatarString:String?
  var account:BehaviorRelay<Account?> = BehaviorRelay(value: nil)
  
  var balances:BehaviorRelay<[Balance]?> = BehaviorRelay(value: nil)
  var limitOrder:BehaviorRelay<[LimitOrder]?> = BehaviorRelay(value:nil)
  var fillOrder:BehaviorRelay<[(FillOrder,time:String)]?> = BehaviorRelay(value:nil)
  
  var timer:Repeater?
  
  var limitOrderValue:Double = 0
  var limitOrder_buy_value: Double = 0
  
  var limit_reset_address_time : TimeInterval = 0
  
  var balance : Double {
    
    var balance_values:Double = 0
    var _limitOrderValue:Double = 0
    var _limitOrder_buy_value:Double = 0
    
    if let balances = balances.value {
      for balance_value in balances{
        if let eth_cyb = changeToETHAndCYB(balance_value.asset_type).cyb.toDouble() {
          balance_values += getRealAmount(balance_value.asset_type,amount: balance_value.balance).doubleValue * eth_cyb
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
            let buy_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale).doubleValue * eth_cyb
            _limitOrderValue += buy_value
            _limitOrder_buy_value += buy_value
            balance_values += buy_value
          }
        }
        else{
          if let eth_cyb = changeToETHAndCYB(limitOrder_value.sellPrice.base.assetID).cyb.toDouble() {
            let sell_value = getRealAmount(limitOrder_value.sellPrice.base.assetID, amount: limitOrder_value.forSale).doubleValue * eth_cyb
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
  
  func timingLock() {
    self.timer = Repeater.once(after: .seconds(300), {[weak self] (timer) in
      guard let `self` = self else { return }
      self.keys = nil
    })
    
    timer?.start()
  }
  
  private init() {
    
    app_data.data.asObservable().distinctUntilChanged()
//      .filter({$0.count = AssetConfiguration.shared.asset_ids.count})
      .throttle(3, latest: true, scheduler: MainScheduler.instance)
      .subscribe(onNext: { (s) in
        DispatchQueue.main.async {
          if UserManager.shared.isLoginIn && AssetConfiguration.shared.asset_ids.count > 0 {
            UserManager.shared.fetchAccountInfo()
          }
          
        }
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
    account.asObservable().skip(1).subscribe(onNext: {[weak self] (newAccount) in
      guard let `self` = self else { return }
      
      self.fetchHistoryOfOperation()
    }).disposed(by: disposeBag)
    
  }
  
  
  private func saveName(_ name:String) {
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


