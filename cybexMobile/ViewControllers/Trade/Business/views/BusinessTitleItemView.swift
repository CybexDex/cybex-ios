//
//  BusinessTitleItemView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class BusinessTitleItemView: UIView {
  enum event:String {
    case cellClicked
  }

    @IBOutlet weak var paris: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var total: UILabel!
    var selectedIndex : Int?
  
    var data : Any?{
    didSet{
        guard let markets = data as? HomeBucket else { return }
        self.paris.text = markets.quote_info.symbol.filterJade + "/" + markets.base_info.symbol.filterJade
      if markets.bucket.count == 0{
        self.total.text = "-"
        self.change.text = "-"
        return
      }
        let matrix = getCachedBucket(markets)
        self.total.text = " " + matrix.quote_volume
      
        self.change.text = (matrix.incre == .greater ? "+" : "") + matrix.change.formatCurrency(digitNum: 2) + "%"
        if let change = matrix.change.toDouble() ,change > 1000{
            self.change.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        }else{
            self.change.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        }
        self.change.textColor = matrix.incre.color()
    }
  }
  
  
  func setup(){
    self.isUserInteractionEnabled = true
    self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      if let markets = self.data as? HomeBucket{
        self.next?.sendEventWith(event.cellClicked.rawValue, userinfo: ["info": Pair(base: markets.base, quote: markets.quote), "index": self.selectedIndex ?? 0])
      }
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

}
