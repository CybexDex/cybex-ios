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

}

class UserManager {
  static let shared = UserManager()
  
  var keys:AccountKeys?
  var avatarString:String?
  var account:Account?
  var limitOrders:[LimitOrder]?
  var balances:[Balance]?
  
  
  private init() {
    
  }
  
  private func generateKeys(_ username:String, password:String) {
    let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
    
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
