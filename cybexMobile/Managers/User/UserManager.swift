//
//  UserManager.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftyJSON

extension UserManager {
  
  func login(_ username:String, password:String) {
    generateKeys(username, password: password)
  }
  
  func validateLogin() {
    
  }
  
  func register() {
    
  }

}

class UserManager {
  static let shared = UserManager()
  
  var keys:AccountKeys?
  
  private init() {
    
  }
  
  private func generateKeys(_ username:String, password:String) {
    let keysString = BitShareCoordinator.getUserKeys(username, password: password)!
    
    if let keys = AccountKeys(JSONString: keysString) {
      self.keys = keys
    }
    
  }
  
  
  
}
