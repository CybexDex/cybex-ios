//
//  AccountPortfolioCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class AccountPortfolioCellView: UIView{
  
  var data: Any? {
    didSet {
      guard let balance = data as? Balance else { return }
//      icon.image  = UIImage(named: "")
      
      name.text   = app_data.assetInfo[balance.asset_type]?.symbol.filterJade ?? "--"
      amount.text = getRealAmount(balance.asset_type, amount: balance.balance).toString
      
      price.text  = changeToETHAndCYB(balance.asset_type).cyb == "" ? "--" :  String(changeToETHAndCYB(balance.asset_type).cyb.toDouble()! * (amount.text?.toDouble())!)
      + " CYB"
    }
  }
  @IBOutlet weak var icon: UIImageView!
  
  @IBOutlet weak var name: UILabel!
  
  @IBOutlet weak var amount: UILabel!
  
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
