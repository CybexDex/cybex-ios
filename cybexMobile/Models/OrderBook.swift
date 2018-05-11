//
//  OrderBook.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/10.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import ObjectMapper


class LimitOrder : ImmutableMappable {
  let id: String
  let expiration: String
  let seller: String
  let forSale: String
  let sellPrice: Price
  
  required  init(map: Map) throws {
    id                   = try map.value("id")
    expiration           = try map.value("expiration")
    seller               = try map.value("seller")
    forSale              = try map.value("for_sale", using: ToStringTransform())
    sellPrice            = try map.value("sell_price")
  }

  func mapping(map: Map) {
    id                   >>> map["id"]
    expiration           >>> map["expiration"]
    seller               >>> map["seller"]
    forSale              >>> (map["for_sale"], ToStringTransform())
    sellPrice            >>> map["sell_price"]
  }
}
