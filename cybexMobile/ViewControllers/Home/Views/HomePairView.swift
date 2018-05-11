//
//  HomePairView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import EZSwiftExtensions
import RxGesture
import Kingfisher

@IBDesignable
class HomePairView: UIView {
  
  enum event:String {
    case cellClicked
  }

  @IBOutlet weak var icon: UIImageView!
  
  @IBOutlet weak var asset1: UILabel!
  @IBOutlet weak var asset2: UILabel!
  
  @IBOutlet weak var volume: UILabel!
  
  @IBOutlet weak var high_low: UILabel!
  @IBOutlet weak var price: UILabel!
  
  @IBOutlet weak var bulkingIcon: UIImageView!
  @IBOutlet weak var bulking: UILabel!
  @IBOutlet weak var total_time: UILabel!

  var base:String!
  var quote:String!
  var data: Any? {
    didSet {
      guard let markets = data as? HomeBucket else { return }
      
      self.asset1.text = markets.base_info.symbol
      self.asset2.text = "/" + markets.quote_info.symbol
      
      let iconString = AppConfiguration.SERVER_ICONS_BASE_URLString + markets.quote.replacingOccurrences(of: ".", with: "_") + "_grey.png"
      self.icon.kf.setImage(with: URL(string: iconString))
      
      if markets.bucket.count == 0 {
        self.volume.text = "V: -"
        self.high_low.text = "H: - L: -"
        self.price.text = "-"
        self.bulking.text = "-"
        self.bulkingIcon.image = #imageLiteral(resourceName: "ic_arrow_grey2.pdf")
        self.bulking.textColor = #colorLiteral(red: 0.9999966025, green: 0.9999999404, blue: 0.9999999404, alpha: 0.5)
        return
      }
      
      DispatchQueue.global().async {
        let matrix = BucketMatrix(markets)
        
        DispatchQueue.main.async {
          self.volume.text = "V: " + matrix.base_volume
          self.high_low.text = "H: " + matrix.high + " L: " + matrix.low
          self.price.text = matrix.price
          self.bulking.text = (matrix.incre == .greater ? "+" : "") + matrix.change + "%"
          self.bulking.textColor = matrix.incre.color()
          self.bulkingIcon.image = matrix.incre.icon()
        }
      }
    }
  }
  
  
  fileprivate func setup() {
    self.isUserInteractionEnabled = true
    self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      
      self.next?.sendEventWith(event.cellClicked.rawValue, userinfo: ["index": self.store["index"] ?? []])
      
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
