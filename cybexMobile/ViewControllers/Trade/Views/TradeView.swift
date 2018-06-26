//
//  TradeView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TradeView: UIView {
  enum event:String {
    case orderbookClicked
  }
  
  @IBOutlet weak var titlePrice: UILabel!
  
  @IBOutlet weak var titleAmount: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var rmbPrice: UILabel!
  
  @IBOutlet weak var sells: UIStackView!
  @IBOutlet weak var buies: UIStackView!
  
  @IBOutlet var items: [TradeLineView]!
  
  var data : Any? {
    didSet{
      if let data = data as? OrderBook {
        let bids = data.bids
        let asks = data.asks
       
        
        for i in 6...10{
          let sell = sells.viewWithTag(i) as! TradeLineView
          if asks.count - 1 >= (i - 6){
            sell.isBuy    = true
            sell.alpha = 1
            
            let max = asks.count >= 5 ? 4 : asks.count - 1
            let percent = asks[i - 6].volume_percent / asks[max].volume_percent
            
            sell.data     = (asks[i - 6], percent)
          }else{
            sell.alpha = 0
          }
          let buy = buies.viewWithTag(i) as! TradeLineView
          if bids.count - 1 >= (i - 6){
            sell.isBuy   = false
            buy.alpha = 1
   
            let max = bids.count >= 5 ? 4 : bids.count - 1
            let percent = bids[i - 6].volume_percent / bids[max].volume_percent
            
            buy.data     = (bids[i - 6], percent)
          }else{
            buy.alpha = 0
          }
        }
      }
    }
  }
  
  func setup(){
    for item in items {
      item.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
        guard let `self` = self else { return }
        
        self.next?.sendEventWith(event.orderbookClicked.rawValue, userinfo: ["price": item.price.text ?? "0"])
        
      }).disposed(by: disposeBag)
    }
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
