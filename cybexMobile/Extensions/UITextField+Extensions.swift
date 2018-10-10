//
//  UITextField+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable
class ImageTextField: UITextField {
  
    var textFieldBorderStyle: UITextField.BorderStyle = .none
  
  // Provides left padding for image
  override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var textRect = super.leftViewRect(forBounds: bounds)
    textRect.origin.x += padding
    return textRect
  }
  
  // Provides right padding for image
  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var textRect = super.rightViewRect(forBounds: bounds)
    textRect.origin.x -= padding
    return textRect
  }
  
  @IBInspectable var locali:String {
    set {
      localized_text = newValue.localizedContainer()
      updateView()
    }
    
    get {
      return (localized_text?.value() as! String).localized()
    }
  }
  
  @IBInspectable var fieldImage: UIImage? = nil {
    didSet {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidEndEditingNotification, object: nil)
      
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self, queue: nil) {[weak self] (notifi) in
        self?.leftView?.alpha = 1
      }
      
        NotificationCenter.default.addObserver(forName: UITextField.textDidEndEditingNotification, object: self, queue: nil) {[weak self] (notifi) in
        self?.leftView?.alpha = 0.5
      }
      
      updateView()
    }
  }
  
  @IBInspectable var tailImage: UIImage? = nil {
    didSet {
      updateView()
    }
  }
  
  var activityView: UIActivityIndicatorView? = nil
  
  @IBInspectable var padding: CGFloat = 0
  @IBInspectable var color: UIColor = UIColor.gray {
    didSet {
      updateView()
    }
  }
  @IBInspectable var bottomColor: UIColor = UIColor.clear {
    didSet {
      if bottomColor == UIColor.clear {
        self.borderStyle = .roundedRect
      } else {
        self.borderStyle = .bezel
      }
      self.setNeedsDisplay()
    }
  }
  
  func updateView() {
    if let image = fieldImage {
        leftViewMode = UITextField.ViewMode.always
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
      imageView.image = image
      // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
      imageView.tintColor = color
      imageView.alpha = leftView?.alpha ?? 0.5
      
      leftView = imageView
    } else {
        leftViewMode = UITextField.ViewMode.never
      leftView = nil
    }

    if let image = tailImage {
        rightViewMode = UITextField.ViewMode.always
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
      imageView.image = image
      // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
      imageView.tintColor = color
      rightView = imageView

      if self.activityView == nil {
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.frame = imageView.bounds
        activityView.style = ThemeManager.currentThemeIndex == 0 ? .white : .gray
        activityView.startAnimating()
        rightView?.addSubview(activityView)
        self.activityView = activityView
        self.activityView?.isHidden = true
      }
    } else {
        rightViewMode = UITextField.ViewMode.never
      rightView = nil
    }
    // Placeholder text color

    attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
  }
  
  override func draw(_ rect: CGRect) {
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: self.bounds.origin.x, y: self.bounds.height
      - 1))
    path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.height
      - 1))
    path.lineWidth = 1
    self.bottomColor.setStroke()
    path.stroke()
  }
  
  @objc func willDealloc() -> Bool {
    return false
  }
}
