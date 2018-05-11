//
//  Collection+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension Collection {
  subscript(optional i: Index) -> Iterator.Element? {
    return self.indices.contains(i) ? self[i] : nil
  }
}

extension Array where Element: Hashable {
  func containHashable<T:Hashable>(_ element: T) -> (Contain:Bool, Index:Int) {
    let hash_num = self.map { $0.hashValue }
    if let index = hash_num.index(of: element.hashValue) {
      return (true, index)
    }
    return (false, 0)
  }
}
