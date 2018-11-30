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
    var locali: String {
        set {
            localizedText = newValue.localizedContainer()
        }

        get {
            if let val = localizedText?.value() as? String {
                return val.localized()
            }
            return ""
        }
    }
}

extension UIButton {
    @IBInspectable
    var locali: String {
        set {
            localizedText = newValue.localizedContainer()
        }

        get {
            if let val = localizedText?.value() as? String {
                return val.localized()
            }
            return ""
        }
    }
}

extension UISegmentedControl {
    @IBInspectable
    var locali0: String {
        set {
            localizedText0 = newValue.localizedContainer()
        }

        get {
            return ""
        }
    }

    @IBInspectable
    var locali1: String {
        set {
            localizedText1 = newValue.localizedContainer()
        }

        get {
            return ""
        }
    }

    @IBInspectable
    var locali2: String {
        set {
            localizedText2 = newValue.localizedContainer()
        }

        get {
            return ""
        }
    }
}

extension UISegmentedControl {
    var localizedText0: LocalizedValueContainer? {
        get { return nil }
        set { setOperation(self, #selector(UISegmentedControl.setTitle(_:forSegmentAt:)), SegmentValueContainer(picker: newValue, withIndex: 0)) }
    }
    var localizedText1: LocalizedValueContainer? {
        get { return nil }
        set { setOperation(self, #selector(UISegmentedControl.setTitle(_:forSegmentAt:)), SegmentValueContainer(picker: newValue, withIndex: 1)) }
    }
    var localizedText2: LocalizedValueContainer? {
        get { return nil }
        set { setOperation(self, #selector(UISegmentedControl.setTitle(_:forSegmentAt:)), SegmentValueContainer(picker: newValue, withIndex: 2)) }
    }
}

extension UIButton {
    var localizedText: LocalizedValueContainer? {
        get { return nil }
        set { setOperation(self, #selector(UIButton.setTitle(_:for:)), StateValueContainer(picker: newValue, withState: .normal)) }
    }
}

extension UILabel {
    var localizedText: LocalizedValueContainer? {
        get { return getOperation(self, #selector(getter: UILabel.text)) as? LocalizedValueContainer }
        set { setOperation(self, #selector(setter: UILabel.text), newValue) }
    }
}

extension UITextField {
    var localizedText: LocalizedValueContainer? {
        get { return getOperation(self, #selector(getter: UITextField.placeholder)) as? LocalizedValueContainer }
        set { setOperation(self, #selector(setter: UITextField.placeholder), newValue) }
    }
}

extension UIViewController {
    var localizedText: LocalizedValueContainer? {
        get { return getOperation(self, #selector(getter: UIViewController.title)) as? LocalizedValueContainer }
        set { setOperation(self, #selector(setter: UIViewController.title), newValue) }
    }
}

extension UITabBarItem {
    var localizedText: LocalizedValueContainer? {
        get { return getOperation(self, #selector(getter: UITabBarItem.title)) as? LocalizedValueContainer }
        set { setOperation(self, #selector(setter: UITabBarItem.title), newValue) }
    }
}

extension NSString {
    func localizedContainer() -> LocalizedValueContainer {
        return LocalizedValueContainer(val: { self })
    }
}

private func getOperation(
    _ object: NSObject,
    _ selector: Selector
    ) -> ValueContainer? {
    return object.changeOperations[selector]
}

private func setOperation(
    _ object: NSObject,
    _ selector: Selector,
    _ picker: ValueContainer?
    ) {
    object.changeOperations[selector] = picker
    if let control = object as? UIControl {
        control.performControlOperations(sel: selector, picker: picker)
        return
    }
    object.performOperations(sel: selector, picker: picker)
}

class ValueContainer: NSObject, NSCopying {

    public typealias ValueType = () -> Any?

    public var value: ValueType

    required public init(val: @escaping ValueType) {
        value = val
    }

    public func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(val: value)
    }
}

final class StateValueContainer: ValueContainer {

    typealias ValuesType = [UInt: ValueContainer]

    var values = ValuesType()

    convenience init?(picker: ValueContainer?, withState state: UIControl.State) {
        guard let picker = picker else { return nil }

        self.init(val: { 0 })
        values[state.rawValue] = picker
    }

    func setPicker(_ picker: ValueContainer?, forState state: UIControl.State) -> Self {
        values[state.rawValue] = picker
        return self
    }
}

final class SegmentValueContainer: ValueContainer {

    typealias ValuesType = [Int: ValueContainer]

    var values = ValuesType()

    convenience init?(picker: ValueContainer?, withIndex index: Int) {
        guard let picker = picker else { return nil }

        self.init(val: { 0 })
        values[index] = picker
    }

    func setPicker(_ picker: ValueContainer?, withIndex index: Int) -> Self {
        values[index] = picker
        return self
    }
}

final class LocalizedValueContainer: ValueContainer, ExpressibleByStringLiteral {
    public required convenience init(stringLiteral value: String) {
        self.init(val: { value })
    }

    public required convenience init(unicodeScalarLiteral value: String) {
        self.init(val: { value })
    }

    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(val: { value })
    }
}

// MARK: - Perform Stored Operation

private var operationKey = 2018
extension NSObject {
    typealias Operations = [Selector: ValueContainer]

    var changeOperations: Operations {
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
            let setLocalizedText = unsafeBitCast(method(for: sel), to: SetLocalizedTextIMP.self)
            if let val = value as? String {
                setLocalizedText(self, sel, val.localized())
            }
            //Compatible Swift Rich String
            if let label = self as? UILabel, let _ = label.styleName {
                label.styledText = label.text
            }
        } else { perform(sel, with: value) }
    }
    fileprivate typealias SetLocalizedTextIMP        = @convention(c) (NSObject, Selector, String) -> Void
}

extension UIControl {
    func performControlOperations(sel: Selector, picker: ValueContainer?) {
        guard responds(to: sel)           else { return }
        guard let value = picker?.value() else { return }

        if picker is LocalizedValueContainer {
            let setLocalizedText = unsafeBitCast(method(for: sel), to: SetLocalizedTextIMP.self)
            if let val = value as? String {
                setLocalizedText(self, sel, val.localized())
            }
        } else if let statePicker = picker as? StateValueContainer {
            let setState = unsafeBitCast(method(for: sel), to: SetLocalizedTextForStateIMP.self)

            statePicker.values.forEach {
                if let val = $1.value() as? String {
                    setState(self, sel, val.localized(), UIControl.State(rawValue: $0))
                }
            }
        } else if let statePicker = picker as? SegmentValueContainer {
            let setState = unsafeBitCast(method(for: sel), to: SetLocalizedTextForSegmentIMP.self)
            statePicker.values.forEach {
                if let val = $1.value() as? String {
                    setState(self, sel, val.localized(), $0)
                }
            }
        } else { perform(sel, with: value) }

    }

    fileprivate typealias SetLocalizedTextForStateIMP       = @convention(c) (NSObject, Selector, String, UIControl.State) -> Void
    fileprivate typealias SetLocalizedTextForSegmentIMP       = @convention(c) (NSObject, Selector, String, Int) -> Void

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
        self.changeOperations.forEach {[weak self] selector, picker in
            UIView.animate(withDuration: 0.3) {
                guard let `self` = self else { return }
                if let control = self as? UIControl {
                    control.performControlOperations(sel: selector, picker: picker)
                    return
                }
                self.performOperations(sel: selector, picker: picker)
            }
        }
    }
}
