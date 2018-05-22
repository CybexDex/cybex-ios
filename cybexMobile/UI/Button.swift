//
//  Button.swift
//  cybexMobile
//
//  Created by koofrank on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class Button:UIView {
  @IBOutlet weak var button: UIButton!
  
  @IBInspectable var locali:String? {
    didSet {
      self.button.locali = locali!
      updateView()
    }
  }
  
  @IBInspectable var isEnable: Bool = false {
    didSet {
      self.button.isEnabled = isEnable
      updateView()
    }
  }
  
  let gradientLayer: LinearGradientLayer = {
    let gradientLayer = LinearGradientLayer()
    gradientLayer.colors = [UIColor.peach.cgColor, UIColor.maincolor.cgColor]
    return gradientLayer
  }()
  
  func updateView() {
    if isEnable {
      gradientLayer.isHidden = false
    }
    else {
      gradientLayer.isHidden = true
    }
  }
  
  fileprivate func setup() {
    gradientLayer.frame = self.bounds
    self.button.layer.addSublayer(gradientLayer)
    self.button.isUserInteractionEnabled = false
    self.button.setBackgroundColor(.steel30, forState: UIControlState.disabled)
    
    self.button.setTitleColor(.white30, for: UIControlState.disabled)
    self.button.setTitleColor(.white, for: UIControlState.normal)
    
    updateView()
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIViewNoIntrinsicMetric,height: dynamicHeight())
  }
  
  fileprivate func updateHeight() {
    layoutIfNeeded()
    self.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  fileprivate func dynamicHeight() -> CGFloat {
    let lastView = self.subviews.last?.subviews.last
    return lastView!.bottom
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
    gradientLayer.frame = self.bounds
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    loadViewFromNib()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadViewFromNib()
    setup()
  }
  
  fileprivate func loadViewFromNib() {
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }

}
