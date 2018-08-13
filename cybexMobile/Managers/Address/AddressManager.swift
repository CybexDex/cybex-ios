//
//  AddressManager.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/10.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class AddressManager: NSObject {
  static let shared = AddressManager()
  
  func addAddress() {
    
  }
  
  func deleteAddress() {
    
  }
  
  func changeAddress() {
    
  }
  
  func fetchAllAddress() {
    
  }
  
}

struct Address {
  var name : String = ""
  var address : String = ""
  var memo : String = ""
  var asset : String = ""
}
