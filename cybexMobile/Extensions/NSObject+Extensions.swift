//
//  NSObject+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import RxSwift

extension NSObject {
  // Swift extensions *can* add stored properties
  // https://medium.com/@ttikitu/swift-extensions-can-add-stored-properties-92db66bce6cd
  func associatedObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
      if let associated = objc_getAssociatedObject(base, key)
        as? ValueType { return associated }
      let associated = initialiser()
      objc_setAssociatedObject(base, key, associated,
                               .OBJC_ASSOCIATION_RETAIN)
      return associated
  }
  
  func associateObject<ValueType: AnyObject>(
    base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
    objc_setAssociatedObject(base, key, value,
                             .OBJC_ASSOCIATION_RETAIN)
  }
}

private var bagKey: UInt8 = 0
private var storeKey: UInt8 = 1

extension NSObject {
  var store: [String:Any] {
    get {
      if let storeData = objc_getAssociatedObject(self, &storeKey) {
        return storeData as! [String : Any]
      }
      return [:]
    }
    set {
      objc_setAssociatedObject(self, &storeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

extension NSObject {
  var disposeBag: DisposeBag {
    get {
      return associatedObject(base: self, key: &bagKey, initialiser: { return DisposeBag()})
    }
    set {
      associateObject(base: self, key: &bagKey, value: newValue)
    }
  }
}
