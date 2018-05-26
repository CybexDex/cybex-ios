//
//  UIView+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

import Localize_Swift

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
  
  var centerX: CGFloat{
    get { return self.center.x }
    set { self.center = CGPoint(x: newValue,y: self.centerY) }
  }
  
  var centerY: CGFloat {
    get { return self.center.y }
    set { self.center = CGPoint(x: self.centerX,y: newValue) }
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
