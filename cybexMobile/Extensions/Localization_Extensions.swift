//
//  Localization_Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift
import SwiftTheme

extension UILabel {
  @IBInspectable
  var locali:String {
    set {
      localized_text = newValue.localizedContainer()
    }
    
    get {
      return (localized_text?.value() as! String).localized()
    }
  }
}

extension UIButton {
  @IBInspectable
  var locali:String {
    set {
      localized_text = newValue.localizedContainer()
    }
    
    get {
      return (localized_text?.value() as! String).localized()
    }
  }
}

extension UIButton {
  var localized_text: LocalizedValueContainer? {
    get { return getOperation(self, #selector(getter: UIButton.currentTitle)) as? LocalizedValueContainer }
    set { setOperation(self, #selector(UIButton.setTitle(_:for:)), StateValueContainer(picker: newValue, withState: .normal)) }
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

extension NSString {
  func localizedContainer() -> LocalizedValueContainer {
    return LocalizedValueContainer(v: { self })
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

final class StateValueContainer: ValueContainer {
  
  typealias ValuesType = [UInt: ValueContainer]
  
  var values = ValuesType()
  
  convenience init?(picker: ValueContainer?, withState state: UIControlState) {
    guard let picker = picker else { return nil }
    
    self.init(v: { 0 })
    values[state.rawValue] = picker
  }
  
  func setPicker(_ picker: ValueContainer?, forState state: UIControlState) -> Self {
    values[state.rawValue] = picker
    return self
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

// MARK: - Perform Stored Operation

private var operationKey = 2018
extension NSObject {
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
    else if let statePicker = picker as? StateValueContainer {
      let setState = unsafeBitCast(method(for: sel), to: setLocalizedTextForStateIMP.self)
      statePicker.values.forEach { setState(self, sel, ($1.value()! as! String).localized(), UIControlState(rawValue: $0)) }
    }
      
    else { perform(sel, with: value) }
    
  }
  fileprivate typealias setLocalizedTextIMP        = @convention(c) (NSObject, Selector, String) -> Void
  fileprivate typealias setLocalizedTextForStateIMP       = @convention(c) (NSObject, Selector, String, UIControlState) -> Void

}

// MARK: - Observe Localization Changed

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
