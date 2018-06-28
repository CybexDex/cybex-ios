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
    @IBOutlet weak var orderAmount: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var orderPrice: UILabel!
  
    @IBOutlet weak var state: UILabel!
    
  var data : Any? {
    didSet{
      if let fillOrder = data as? (FillOrder,time:String) {
        updateUI(fillOrder)
      }
    }
  }
  
  func updateUI(_ orderInfo: (FillOrder,time:String)) {
    let order = orderInfo.0
    if let quoteInfo = app_data.assetInfo[order.fill_price.quote.assetID], let baseInfo = app_data.assetInfo[order.fill_price.base.assetID],let payInfo = app_data.assetInfo[order.pays.assetID] ,let receiveInfo = app_data.assetInfo[order.receives.assetID]{
      let result = calculateAssetRelation(assetID_A_name: baseInfo.symbol.filterJade, assetID_B_name: quoteInfo.symbol.filterJade)
      if result.base == baseInfo.symbol.filterJade && result.quote == quoteInfo.symbol.filterJade{
        // SEll
        // pay -> quote   receive -> base
        self.asset.text = result.quote
        self.base.text  = "/" + result.base
        self.kindL.text = "SELL"
        self.typeView.backgroundColor = .reddish
        self.amount.text = String(getRealAmount(payInfo.id, amount: order.pays.amount)).formatCurrency(digitNum: payInfo.precision) + " " + result.quote
        self.orderAmount.text = String(getRealAmount(receiveInfo.id, amount: order.receives.amount)).formatCurrency(digitNum: receiveInfo.precision) + " " +  result.base
        self.orderPrice.text = String(getRealAmount(receiveInfo.id, amount: order.receives.amount) / getRealAmount(payInfo.id, amount: order.pays.amount)).formatCurrency(digitNum: 8) + " " + result.base
      }else{
        // BUY   pay -> base receive -> quote
        self.kindL.text               = "BUY"
        self.asset.text = result.quote
        self.base.text  = "/" + result.base
        self.typeView.backgroundColor = .turtleGreen
        self.amount.text = String(getRealAmount(receiveInfo.id, amount:order.receives.amount)).formatCurrency(digitNum: receiveInfo.precision) + " " + result.quote
        self.orderAmount.text = String(getRealAmount(payInfo.id, amount: order.pays.amount)).formatCurrency(digitNum: payInfo.precision) + " " + result.base
        
        self.orderPrice.text = String(getRealAmount(payInfo.id, amount: order.pays.amount) / getRealAmount(receiveInfo.id, amount:order.receives.amount)).formatCurrency(digitNum: 8) + " " + result.base
      }
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      
      let date = dateFormatter.date(from: orderInfo.time.replacingOccurrences(of: "T", with: " "))
      dateFormatter.dateFormat = "MM/dd HH:mm:ss"
      if let date = date{
        self.time.text = dateFormatter.string(from: date)
      }
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
