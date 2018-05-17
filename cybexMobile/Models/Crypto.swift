//
//  Crypto.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/11.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class AccountKeys: Mappable {
  var active_key:Key?
  var owner_key:Key?
  var memo_key:Key?

  required init?(map: Map) {
    
  }

  func mapping(map: Map) {
    active_key <- map["active-key"]
    owner_key <- map["owner-key"]
    memo_key <- map["memo-key"]
  }
}

class Key: Mappable {
  var private_key = ""
  var public_key = ""
  var address = ""
  var compressed = ""
  var uncompressed = ""

  required init?(map: Map) {

  }

  func mapping(map: Map) {
    private_key <- map["private_key"]
    public_key <- map["public_key"]
    address <- map["address"]
    compressed <- map["compressed"]
    uncompressed <- map["uncompressed"]
  }
}
