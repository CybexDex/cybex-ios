//
//  Trade.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/23.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class Fee: Mappable {
  var asset_id : String = ""
  var amount : String = ""
  required init?(map: Map) {
    
  }
  func mapping(map: Map) {
    asset_id    <- map["asset_id"]
    amount      <- map["amount"]
  }
}

