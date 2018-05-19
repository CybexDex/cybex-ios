//
//  LockupProgressView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme
@IBDesignable
class LockupProgressView: UIView {
  
  @IBInspectable
  var progress : Double = 0{
    didSet{
      self.setNeedsDisplay()
    }
  }
  @IBInspectable
  var beginColor : UIColor = UIColor.clear {
    didSet{
      
    }
  }
  @IBInspectable
  var endColor:UIColor = UIColor.clear{
    didSet{
      
    }
  }
  
  
  @IBInspectable
  var theme1NormalColor : UIColor = UIColor.clear {
    didSet{
      
    }
  }
  
  @IBInspectable
  var theme2NormalColor : UIColor = UIColor.clear {
    didSet{
      
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // Only override draw() if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override func draw(_ rect: CGRect) {
    if let sublayers = self.layer.sublayers{
      for  layer in sublayers {
        layer.removeFromSuperlayer()
      }
    }
    let beginColor   = self.beginColor.cgColor
    let endColor     = self.endColor.cgColor
    let colorArr     = [beginColor,endColor]
    let gradient          = CAGradientLayer()
    gradient.colors       = colorArr
    gradient.startPoint   = CGPoint(x: 0, y: 0)
    gradient.endPoint     = CGPoint(x: 1, y: 0)
    gradient.frame       = self.bounds
    self.layer.insertSublayer(gradient, at: 0)
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: CGFloat(self.progress)*rect.width, y: rect.height * 0.5))
    path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.5))
    path.lineWidth = rect.height
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.cgPath
    shapeLayer.lineWidth = rect.height
    
    if (ThemeManager.currentThemeIndex == 0) {
      shapeLayer.strokeColor = self.theme1NormalColor.cgColor
    }else{
      shapeLayer.strokeColor = self.theme2NormalColor.cgColor
    }
    self.layer.addSublayer(shapeLayer)
  }
}
