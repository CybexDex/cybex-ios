//
//  Operation.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper

class Transfer: Mappable, NSCopying {
  var from: String = ""
  var to: String = ""
  var fee: Asset = Asset(JSON: [:])!
  var amount: Asset = Asset(JSON: [:])!

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    from                   <- (map["from"], ToStringTransform())
    to          <- (map["to"], ToStringTransform())
    fee         <- map["fee"]
    amount            <- map["amount"]
  }

  func copy(with zone: NSZone? = nil) -> Any {
    let copy = Transfer(JSON: self.toJSON())!
    return copy
  }

  static func empty() -> Transfer {
    return Transfer(JSON: [:])!
  }
}

class FillOrder: Mappable, NSCopying {
  var fill_price: Price = Price(JSON: [:])!
  var fee: Asset = Asset(JSON: [:])!
  var pays: Asset = Asset(JSON: [:])!
  var receives: Asset = Asset(JSON: [:])!
  var is_maker: Int = 0 //0 1
  var block_num: Int = 0

  required init?(map: Map) {
  }

  func mapping(map: Map) {
    fill_price                   <- map["fill_price"]
    fee                   <- map["fee"]
    pays                   <- map["pays"]
    receives                   <- map["receives"]
    is_maker                   <- map["is_maker"]
    block_num                   <- map["block_num"]
  }

  func copy(with zone: NSZone? = nil) -> Any {
    let copy = FillOrder(JSON: self.toJSON())!
    return copy
  }

  static func empty() -> FillOrder {
    return FillOrder(JSON: [:])!
  }
}
