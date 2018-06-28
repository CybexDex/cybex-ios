//
//  MyHistoryCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class MyHistoryCellView: UIView {
  
  @IBOutlet weak var asset: UILabel!
  @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var base: UILabel!
    
  @IBOutlet weak var kindL: UILabel!
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var orderPrice: UILabel!
  
    @IBOutlet weak var state: UILabel!
    
  var data : Any? {
    didSet{
      if let fillOrder = data as? FillOrder {
        updateUI(fillOrder)
      }
    }
  }
  
  func updateUI(_ order: FillOrder) {
    if let quoteInfo = app_data.assetInfo[order.fill_price.quote.assetID], let baseInfo = app_data.assetInfo[order.fill_price.base.assetID] {
      if order.pays.assetID == order.fill_price.quote.assetID{
        self.asset.text = quoteInfo.symbol.filterJade
        self.base.text  = "/" + baseInfo.symbol.filterJade
        self.kindL.text               = "BUY"
        self.typeView.backgroundColor = .turtleGreen
        self.amount.text = getRealAmount(order.receives.assetID, amount: order.receives.amount).stringValue + baseInfo.symbol.filterJade
        self.price.text = getRealAmount(order.pays.assetID, amount: order.pays.amount).stringValue +
          quoteInfo.symbol.filterJade
      }else{
        self.asset.text = baseInfo.symbol.filterJade
        self.base.text  = "/" + quoteInfo.symbol.filterJade
        self.kindL.text = "SELL"
        self.typeView.backgroundColor = .reddish
        self.amount.text = getRealAmount(order.pays.assetID, amount: order.pays.amount).stringValue + baseInfo.symbol.filterJade
        self.price.text = getRealAmount(order.receives.assetID, amount: order.receives.amount).stringValue + quoteInfo.symbol.filterJade
      }
        
        self.orderPrice.text = self.price.text
    }
  }
  
  func setup(){
    
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
    let nibName = String(describing:type(of:self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
}
