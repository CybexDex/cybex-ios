//
//  PairRechargeView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/27.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class PairRechargeView: UIView {
  enum show_type : Int{
    case show = 0
    case hidden
  }
  
  
  var showType : Int?{
    didSet{
      if showType == show_type.show.rawValue{
        self.isHidden = false
      }else{
        self.isHidden = true
      }
    }
  }

    @IBOutlet weak var buy: Button!
    @IBOutlet weak var sell: Button!
  
    fileprivate func setup() {
    buy.gradientLayer.colors =  [UIColor.paleOliveGreen.cgColor,UIColor.apple.cgColor]
        
        sell.gradientLayer.colors = [UIColor.pastelRed.cgColor,UIColor.reddish.cgColor]
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIView.noIntrinsicMetric,height: dynamicHeight())
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
