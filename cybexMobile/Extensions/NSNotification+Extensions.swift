//
//  NSNotification+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

enum CBNotification: String {
  case localizedChanged
  
  var stringValue: String {
    return "CB" + rawValue
  }
  
  var notificationName: NSNotification.Name {
    return NSNotification.Name(stringValue)
  }
}

extension NotificationCenter {
  static func post(customNotification name: CBNotification, object: Any? = nil) {
    NotificationCenter.default.post(name: name.notificationName, object: object)
  }
  
  static func add(customNotification name: CBNotification, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Swift.Void) {
    NotificationCenter.default.addObserver(forName: name.notificationName, object: obj, queue: queue, using: block)
  }
  
  static func remove(_ observer: Any, customNotification name: CBNotification?, object anObject: Any?) {
    NotificationCenter.default.removeObserver(observer, name: name?.notificationName, object: anObject)
  }
}

