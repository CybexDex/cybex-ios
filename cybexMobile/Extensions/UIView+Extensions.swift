//
//  UIView+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme
import TinyConstraints
import Localize_Swift
import ESPullToRefresh

extension UIView {
    var x: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }

    var y: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }

    var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }

    var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }

    var top: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
    var right: CGFloat {
        get { return self.frame.origin.x + self.width }
        set { self.frame.origin.x = newValue - self.width }
    }
    var bottom: CGFloat {
        get { return self.frame.origin.y + self.height }
        set { self.frame.origin.y = newValue - self.height }
    }
    var left: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }

    var centerX: CGFloat {
        get { return self.center.x }
        set { self.center = CGPoint(x: newValue, y: self.centerY) }
    }

    var centerY: CGFloat {
        get { return self.center.y }
        set { self.center = CGPoint(x: self.centerX, y: newValue) }
    }

    var origin: CGPoint {
        set { self.frame.origin = newValue }
        get { return self.frame.origin }
    }
    var size: CGSize {
        set { self.frame.size = newValue }
        get { return self.frame.size }
    }
}

@IBDesignable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
            if let containView = self as? ContainerView {
                containView.newCornerRadius = cornerRadius
                containView.layer.masksToBounds = false
            }
        }
    }

    @IBInspectable var spread: CGFloat {
        get {
            return 0
        }
        set {
            if newValue == 0 {
                layer.shadowPath = nil
            } else {
                let rect = bounds.insetBy(dx: -newValue, dy: -newValue)
                layer.shadowPath = UIBezierPath(rect: rect).cgPath
            }

        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }

    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
}

extension UIView {
    public func edgesToDevice(vc: UIViewController, insets: TinyEdgeInsets = .zero, priority: LayoutPriority = .required, isActive: Bool = true, usingSafeArea: Bool = false) {
        if #available(iOS 11.0, *) {
            edgesToSuperview(insets: insets, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
        } else {
            prepareForLayout()
            let constraints = [
                topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor, constant: insets.top).with(priority),
                leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: insets.left).with(priority),
                bottomAnchor.constraint(equalTo: vc.bottomLayoutGuide.topAnchor, constant: insets.bottom).with(priority),
                trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: insets.right).with(priority)
            ]

            if isActive {
                Constraint.activate(constraints)
            }
        }

    }

    public func topToDevice( _ vc: UIViewController, offset: CGFloat = 0, relation: ConstraintRelation = .equal, priority: LayoutPriority = .required, isActive: Bool = true, usingSafeArea: Bool = false) -> Constraint {
        if #available(iOS 11.0, *) {
            return topToSuperview(nil, offset: offset, relation: relation, priority: priority, isActive: isActive, usingSafeArea: usingSafeArea)
        } else {
            prepareForLayout()

            switch relation {
            case .equal: return topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor, constant: offset).with(priority).set(active: isActive)
            case .equalOrLess: return topAnchor.constraint(lessThanOrEqualTo: vc.topLayoutGuide.bottomAnchor, constant: offset).with(priority).set(active: isActive)
            case .equalOrGreater: return topAnchor.constraint(greaterThanOrEqualTo: vc.topLayoutGuide.bottomAnchor, constant: offset).with(priority).set(active: isActive)
            }
        }
    }
}

extension UIView {
    var noDataView: WithNoDataView? {
        get {
            for subview in self.subviews {
                if let nodataview = subview as? WithNoDataView {
                    return nodataview
                }
            }

            return nil
        }
        set {
            if let newValue = newValue {
                self.addSubview(newValue)
                //        newValue.edgesToSuperview(insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), priority: .required, isActive: true, usingSafeArea: true)
            }
        }
    }

    func showNoData(_ noticeWord: String, icon: String) {
        if let _ = self.noDataView {
            self.noDataView?.notice_word = noticeWord
            self.noDataView?.icon_name = icon
        } else {
            let nodata = WithNoDataView(frame: self.bounds)
            self.noDataView = nodata
            self.noDataView?.notice_word = noticeWord
            self.noDataView?.icon_name = icon
        }
    }

    func showNoData(_ noticeWord: String) {
        if let _ = self.noDataView {
            self.noDataView?.notice_word = noticeWord
        } else {
            let nodata = WithNoDataView(frame: self.bounds)
            self.noDataView = nodata
            self.noDataView?.notice_word = noticeWord
            self.noDataView?.noticeContairner.constant = -64
        }
    }

    func hiddenNoData() {
        self.noDataView?.removeFromSuperview()
        self.noDataView = nil
    }
}
