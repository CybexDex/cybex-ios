//
//  Account.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class Account: Mappable {
  var membership_expiration_date:String = ""
  var name:String = ""
  var active_auths:[Any] = []
  var owner_auths:[Any] = []
  
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
     membership_expiration_date    <- (map["membership_expiration_date"],ToStringTransform())
     name                   <- (map["name"],ToStringTransform())
     active_auths <- map["active.key_auths"]
     owner_auths <- map["owner.key_auths"]
  }
}

extension Account {
  var superMember:Bool {
    let second = membership_expiration_date.dateFromISO8601?.timeIntervalSince1970 ?? 1
    
    return second < 0
  }
}
