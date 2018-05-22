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
      guard let balance = data as? Balance else { return }
      
      let iconString = AppConfiguration.SERVER_ICONS_BASE_URLString + balance.asset_type.replacingOccurrences(of: ".", with: "_") + "_grey.png"
      self.icon.kf.setImage(with: URL(string: iconString))
      
      name.text   = app_data.assetInfo[balance.asset_type]?.symbol.filterJade ?? "--"
      // 获得自己的个数
      realAmount.text = getRealAmount(balance.asset_type, amount: balance.balance).toString
        
      // 获取对应CYB的个数
      let amountCYB = changeToETHAndCYB(balance.asset_type).cyb == "" ? "--" :  String(changeToETHAndCYB(balance.asset_type).cyb.toDouble()! * (realAmount.text?.toDouble())!)
      
      cybPrice.text  = amountCYB + " CYB"
      
      if let cybCount = amountCYB.toDouble() {
        price.text    = "≈¥" + String(cybCount * changeToETHAndCYB("1.3.0").eth.toDouble()! * app_state.property.eth_rmb_price).formatCurrency(digitNum: 2)
      }else{
        price.text    = "--"
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
