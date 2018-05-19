//
//  Balance.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/18.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class Balance: Mappable {
  var asset_type:String = ""
  var balance:String = ""
  
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    asset_type <- (map["asset_type"], ToStringTransform())
    balance <- (map["balance"], ToStringTransform())
  }
}

