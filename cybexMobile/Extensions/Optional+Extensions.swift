//
//  Optional+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    switch self {
    case let collection?:
      return collection.isEmpty
    case nil:
      return true
    }
  }
}
