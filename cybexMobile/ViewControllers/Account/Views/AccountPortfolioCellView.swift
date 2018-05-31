//
//  AccountPortfolioCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Kingfisher

class AccountPortfolioCellView: UIView{
  
  var data: Any? {
    didSet {
      guard let portfolio = data as? PortfolioData else { return }
      
      self.icon.kf.setImage(with: URL(string: portfolio.icon))
      name.text   = portfolio.name
      realAmount.text = portfolio.realAmount
      cybPrice.text  = portfolio.cybPrice
      if portfolio.rbmPrice == "-"{
        price.isHidden = true
      }else{
        price.isHidden = false
        price.text  = portfolio.rbmPrice
      }
    }
  }
  
  @IBOutlet weak var icon: UIImageView!
  
  @IBOutlet weak var name: UILabel!
  
  @IBOutlet weak var realAmount: UILabel!
  
  @IBOutlet weak var cybPrice: UILabel!
    
  @IBOutlet weak var price: UILabel!
  fileprivate func setup() {
    
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
