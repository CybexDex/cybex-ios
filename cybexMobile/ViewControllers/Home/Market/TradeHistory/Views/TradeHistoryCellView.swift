//
//  TradeHistoryCellView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class TradeHistoryCellView:UIView {
    
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var asset_quote: UILabel!
    @IBOutlet weak var asset_base: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var data: Any? {
    didSet {
      guard let showData = data as? (Bool, String, String, String, String)else { return }
      
      self.price.textColor = showData.0 ? #colorLiteral(red: 0.4922918081, green: 0.7674361467, blue: 0.356476903, alpha: 1) : #colorLiteral(red: 0.7984321713, green: 0.3588138223, blue: 0.2628142834, alpha: 1)
      self.price.text = showData.1
      self.asset_quote.text = showData.2
      self.asset_base.text = showData.3
      self.dateLabel.text = showData.4
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
