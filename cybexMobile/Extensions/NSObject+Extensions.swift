//
//  NSObject+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import RxSwift

class ValueContainer: NSObject, NSCopying {
  
  public typealias ValueType = () -> Any?
  
  public var value: ValueType
  
  required public init(v: @escaping ValueType) {
    value = v
  }
  
  public func copy(with zone: NSZone?) -> Any {
    return type(of: self).init(v: value)
  }
  
}


final class LocalizedValueContainer: ValueContainer,ExpressibleByStringLiteral {
  public required convenience init(stringLiteral value: String) {
    self.init(v: { value })
  }
  
  public required convenience init(unicodeScalarLiteral value: String) {
    self.init(v: { value })
  }
  
  public required convenience init(extendedGraphemeClusterLiteral value: String) {
    self.init(v: { value })
  }
}

extension NSString {
  func localizedContainer() -> LocalizedValueContainer {
    return LocalizedValueContainer(v: { self })
  }
}

extension UILabel {
  var localized_text: LocalizedValueContainer? {
    get { return getOperation(self, #selector(getter: UILabel.text)) as? LocalizedValueContainer }
    set { setOperation(self, #selector(setter: UILabel.text), newValue) }
  }
}

extension UITextField {
  var localized_text: LocalizedValueContainer? {
    get { return getOperation(self, #selector(getter: UITextField.placeholder)) as? LocalizedValueContainer }
    set { setOperation(self, #selector(setter: UITextField.placeholder), newValue) }
  }
}

extension UIViewController {
  var localized_text: LocalizedValueContainer? {
    get { return getOperation(self, #selector(getter: UIViewController.title)) as? LocalizedValueContainer }
    set { setOperation(self, #selector(setter: UIViewController.title), newValue) }
  }
}

extension UITabBarItem {
  var localized_text: LocalizedValueContainer? {
    get { return getOperation(self, #selector(getter: UITabBarItem.title)) as? LocalizedValueContainer }
    set { setOperation(self, #selector(setter: UITabBarItem.title), newValue) }
  }
}

private func getOperation(
  _ object : NSObject,
  _ selector : Selector
  ) -> ValueContainer? {
  return object.operations[selector]
}

private func setOperation(
  _ object : NSObject,
  _ selector : Selector,
  _ picker : ValueContainer?
  ) {
  object.operations[selector] = picker
  object.performOperations(sel: selector, picker: picker)
}

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
private var operationKey = 2018

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
  
  typealias Operations = [Selector: ValueContainer]
  
  var operations: Operations {
    get {
      if let themePickers = objc_getAssociatedObject(self, &operationKey) as? Operations {
        return themePickers
      }

      let initValue = Operations()
      objc_setAssociatedObject(self, &operationKey, initValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return initValue
    }
    set {
      objc_setAssociatedObject(self, &operationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      _removeNotification()
      if newValue.isEmpty == false { _setupNotification() }
    }
  }
  
  func performOperations(sel: Selector, picker: ValueContainer?) {
    guard responds(to: sel)           else { return }
    guard let value = picker?.value() else { return }

    if picker is LocalizedValueContainer {
      let setLocalizedText = unsafeBitCast(method(for: sel), to: setLocalizedTextIMP.self)
      setLocalizedText(self, sel, (value as! String).localized())
    }
    else { perform(sel, with: value) }

  }
  fileprivate typealias setLocalizedTextIMP        = @convention(c) (NSObject, Selector, String) -> Void

}

@objc extension NSObject {
  fileprivate func _setupNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(_resetOperation), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
  }
  
  fileprivate func _removeNotification() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
  }
  
  fileprivate func _resetOperation() {
    self.operations.forEach {[weak self] selector, picker in
      UIView.animate(withDuration: 0.3) {
        guard let `self` = self else { return }
        self.performOperations(sel: selector, picker: picker)
      }
    }
  }
  
}
