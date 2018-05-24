//
//  OrderBookCellView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class OrderBookCellView:UIView {
    @IBOutlet weak var buy_price: UILabel!
    @IBOutlet weak var buy_volume: UILabel!

    @IBOutlet weak var sell_price: UILabel!
    @IBOutlet weak var sell_volume: UILabel!

    
    @IBOutlet weak var leftBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var rightBoxWidth: NSLayoutConstraint!

  var data: Any? {
    didSet {
      guard let showData = data as? (OrderBook.Order?, OrderBook.Order?) else { return }
      
      if let bid = showData.0 {
        self.buy_price.text = bid.price
        self.buy_volume.text = bid.volume
        self.leftBoxWidth = self.leftBoxWidth.changeMultiplier(multiplier: CGFloat(bid.volume_percent))
      }
      else {
        self.buy_price.text = ""
        self.buy_volume.text = ""
        self.leftBoxWidth = self.leftBoxWidth.changeMultiplier(multiplier: 0.001)
      }
      
//      print("left:\(self.leftBoxWidth.multiplier)  ")
      if let ask = showData.1 {
        self.sell_price.text = ask.price
        self.sell_volume.text = ask.volume
        self.rightBoxWidth = self.rightBoxWidth.changeMultiplier(multiplier: CGFloat(ask.volume_percent))
      }
      else {
        self.sell_price.text = ""
        self.sell_volume.text = ""
        self.rightBoxWidth = self.rightBoxWidth.changeMultiplier(multiplier: 0.001)
      }
//      print("right:\(self.rightBoxWidth.multiplier)  ")

    }
  }
  
  
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
