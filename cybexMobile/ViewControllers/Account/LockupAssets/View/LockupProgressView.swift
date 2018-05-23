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
  
  //  控制渐进的色彩的方向
  // 0 是水平。1是垂直
  @IBInspectable
  var direction : Int = 0{
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
    
    let beginColor        = self.beginColor.cgColor
    let endColor          = self.endColor.cgColor
    let colorArr          = [beginColor,endColor]
    let gradient          = CAGradientLayer()
    gradient.colors       = colorArr
    let x = self.direction == 0 ? 1 : 0
    let y = self.direction == 1 ? 1 : 0
    gradient.startPoint   = CGPoint(x: 0, y: 0)
    gradient.endPoint     = CGPoint(x: x, y: y)
    gradient.frame        = self.bounds
    self.layer.addSublayer(gradient)
    

    let shapeLayer        = CALayer()
    shapeLayer.frame      = CGRect(x: 0, y: 0, width: CGFloat(self.progress)*rect.width, height: rect.height)
    shapeLayer.backgroundColor = UIColor.black.cgColor
    gradient.mask         = shapeLayer
  }
}
