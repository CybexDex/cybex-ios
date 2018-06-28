//
//  OpenedOrdersView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class OpenedOrdersView:  UIView{
  
  @IBOutlet weak var orderType: OpenedOrdersStatesView!
  @IBOutlet weak var quote: UILabel!
  @IBOutlet weak var base: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var price: UILabel!
  
  @IBOutlet weak var basePriceView: UIView!
  @IBOutlet weak var basePrice: UILabel!
  
  @IBOutlet weak var cancleOrder: UIView!
  @IBOutlet weak var cancleL: UILabel!
  @IBOutlet weak var cancleImg: UIImageView!
  
  enum CancleOrder : String{
    case cancleOrderAction
  }
  
  var selectedIndex : IndexPath?
  var data: Any? {
    didSet {
      if let order = data as? LimitOrder {
        if self.basePriceView.isHidden == false{
          self.basePrice.text = "--"
        }
        
        if order.isBuy {
          self.orderType.opened_status = 0
          if let quote_info = app_data.assetInfo[order.sellPrice.quote.assetID] {
            quote.text = quote_info.symbol.filterJade
          }
          if let base_info = app_data.assetInfo[order.sellPrice.base.assetID] {
            base.text = "/" + base_info.symbol.filterJade
          }
          
          let quoteAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
          self.amount.text = quoteAmount.string.formatCurrency(digitNum: app_data.assetInfo[order.sellPrice.quote.assetID]!.precision) + " " +  quote.text!
          
          let baseAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
          self.price.text = (baseAmount / quoteAmount).string.formatCurrency(digitNum: app_data.assetInfo[order.sellPrice.base.assetID]!.precision)
        }
        else {
          self.orderType.opened_status = 1
          
          if let quote_info = app_data.assetInfo[order.sellPrice.base.assetID] {
            quote.text = quote_info.symbol.filterJade
          }
          if let base_info = app_data.assetInfo[order.sellPrice.quote.assetID] {
            base.text = "/" + base_info.symbol.filterJade
          }
          
          let quoteAmount = getRealAmount(order.sellPrice.base.assetID, amount: order.sellPrice.base.amount)
          self.amount.text = quoteAmount.string.formatCurrency(digitNum: app_data.assetInfo[order.sellPrice.base.assetID]!.precision) + " " +  quote.text!
          
          let baseAmount = getRealAmount(order.sellPrice.quote.assetID, amount: order.sellPrice.quote.amount)
          self.price.text = (baseAmount / quoteAmount).string.formatCurrency(digitNum: app_data.assetInfo[order.sellPrice.quote.assetID]!.precision)
        }
      }
    }
  }
  
  
  fileprivate func setup() {
    cancleOrder.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      self.cancleOrder.next?.sendEventWith(CancleOrder.cancleOrderAction.rawValue, userinfo:["selectedIndex":self.selectedIndex?.row ?? 0])
    }).disposed(by: disposeBag)
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
  
  func setupData(_ data : Any,indexPath:IndexPath){
    self.data = data
    self.selectedIndex = indexPath
  }
  
}
