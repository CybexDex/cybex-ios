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
    amount      <- (map["amount"],ToStringTransform())
  }
}



class Current : Mappable{
  var head_block_id : String = ""
  var last_irreversible_block_num : String = ""
  required init?(map: Map) {
    
  }
  func mapping(map: Map) {
    head_block_id               <- map["head_block_id"]
    last_irreversible_block_num <- (map["last_irreversible_block_num"],ToStringTransform())
  }
}

