//
//  PairDetailView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable
class PairDetailView: UIView {
  @IBOutlet weak var price: UILabel!
  @IBOutlet weak var highLabel: UILabel!
  @IBOutlet weak var lowLabel: UILabel!
  @IBOutlet weak var bulkingIcon: UIImageView!
  @IBOutlet weak var bulking: UILabel!
  @IBOutlet weak var baseVolume: UILabel!
  @IBOutlet weak var quoteVolume: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    
  var base_name : String = ""
  var quote_name : String = ""
  
  var data: Any? {
    didSet {
      if let markets = data as? HomeBucket  {
        refreshViewWith(markets)
      }
      else if let markets = data as? CBKLineModel  {
        refreshViewWith(markets)
      }

    }
  }
  
  func refreshViewWith(_ markets: HomeBucket) {
    self.openLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
    self.closeLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
    self.highLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
    self.lowLabel.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
    self.baseVolume.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
    self.quoteVolume.textColor = UIColor.init(hexString: "#656D88")!.withAlphaComponent(0.5)
    self.openLabel.text = ""
    self.closeLabel.text = ""
    
    if markets.bucket.count == 0 {
      self.baseVolume.text = self.base_name + ": -"
      self.quoteVolume.text = self.quote_name + ":-"
      self.highLabel.text = "High: -"
      self.lowLabel.text = "Low: -"
      self.price.text = "-"
      self.bulking.text = "-"
      self.bulkingIcon.image = #imageLiteral(resourceName: "ic_arrow_grey2.pdf")
      self.bulking.textColor = #colorLiteral(red: 0.9999966025, green: 0.9999999404, blue: 0.9999999404, alpha: 0.5)
      return
    }
    
    DispatchQueue.global().async {
      let matrix = BucketMatrix(markets)
      
      DispatchQueue.main.async {
        self.baseVolume.text = self.base_name + ": " + matrix.base_volume
        self.quoteVolume.text = self.quote_name + ": " + matrix.quote_volume
        self.highLabel.text = "High: " + matrix.high
        self.lowLabel.text = "Low: " + matrix.low
        
        self.price.text = matrix.price
        self.bulking.text = (matrix.incre == .greater ? "+" : "") + matrix.change + "%"
        self.bulking.textColor = matrix.incre.color()
        self.bulkingIcon.image = matrix.incre.icon()
      }
      
    }
  }
  
  func refreshViewWith(_ model: CBKLineModel) {
    self.openLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
    self.closeLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
    self.highLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
    self.lowLabel.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
    self.baseVolume.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)
    self.quoteVolume.textColor = (ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.dark)

    self.openLabel.text = "Open: " + model.open.string(digits: model.precision)
    self.closeLabel.text = "Close: " + model.close.string(digits: model.precision)
    self.highLabel.text = "High: " + model.high.string(digits: model.precision)
    self.lowLabel.text = "Low: " + model.low.string(digits: model.precision)
    
    let base_volume_pair =  self.baseVolume.text!.components(separatedBy: ":")
    self.baseVolume.text =  base_volume_pair[0] + ":" + model.volume.suffixNumber(digitNum: 2)
    
    let quote_volume_pair =  self.quoteVolume.text!.components(separatedBy: ":")

    self.quoteVolume.text = quote_volume_pair[0] + ":" + model.towardsVolume.suffixNumber(digitNum: 2)
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
