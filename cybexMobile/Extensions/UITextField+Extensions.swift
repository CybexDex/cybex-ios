//
//  UITextField+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ImageTextField: UITextField {
  
  var textFieldBorderStyle: UITextBorderStyle = .none
  
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
      leftViewMode = UITextFieldViewMode.always
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
      imageView.image = image
      // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
      imageView.tintColor = color
      leftView = imageView
    } else {
      leftViewMode = UITextFieldViewMode.never
      leftView = nil
    }
    
    if let image = tailImage {
      rightViewMode = UITextFieldViewMode.always
      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
      imageView.image = image
      // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
      imageView.tintColor = color
      rightView = imageView
      
      let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
      activityView.frame = imageView.bounds
      activityView.startAnimating()
      rightView?.addSubview(activityView)
      self.activityView = activityView
      self.activityView?.isHidden = true
    } else {
      rightViewMode = UITextFieldViewMode.never
      rightView = nil
    }
    // Placeholder text color
    
    attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: color])
  }
  
  override func draw(_ rect: CGRect) {
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: self.bounds.origin.x, y: self.bounds.height
      - 0.5))
    path.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.height
      - 0.5))
    path.lineWidth = 0.5
    self.bottomColor.setStroke()
    path.stroke()
  }
}
