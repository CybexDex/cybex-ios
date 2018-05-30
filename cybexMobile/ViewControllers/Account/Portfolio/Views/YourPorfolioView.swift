//
//  YourPorfolioView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class YourPorfolioView:  UIView{
  
  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var name: UILabel!
  
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var price: UILabel!
  
  @IBOutlet weak var cybAmount: UILabel!
  
  @IBOutlet weak var rmbPrice: UILabel!
  
  
    @IBOutlet weak var bottomView: UIStackView!
    
  // 如果是CYB 就不显示的下层view
  @IBOutlet weak var high_low_view: UIView!
  @IBOutlet weak var price_cyb: UILabel!
  @IBOutlet weak var high_low_icon: UIImageView!
  @IBOutlet weak var high_low_label: UILabel!
  
  var data: Any? {
    didSet {
      if let portfolioData = data as? PortfolioData {
        bottomView.isHidden = true

        self.icon.kf.setImage(with: URL(string: portfolioData.icon))
        
        name.text      = portfolioData.name
        amount.text    = portfolioData.realAmount
        if portfolioData.rbmPrice == "-"{
          rmbPrice.isHidden = true
        }else{
          rmbPrice.text  = portfolioData.rbmPrice
        }
        cybAmount.text = portfolioData.cybPrice
        
        
//        high_low_view.isHidden = balance.asset_type == AssetConfiguration.CYB

//        self.icon.kf.setImage(with: URL(string: iconString))
//
//        name.text = app_data.assetInfo[balance.asset_type]?.symbol.filterJade ?? "--"
//
//        amount.text = getRealAmount(balance.asset_type, amount: balance.balance).toString.formatCurrency(digitNum: 5)
//
//        let source =  changeToETHAndCYB(balance.asset_type)
//
//
//        let rmb = source.eth.toDouble() ?? 0
//
//        if rmb == 0 {
//          rmbPrice.text = "--"
//        }else{
//          rmbPrice.text = "≈¥" + String(rmb * (amount.text?.toDouble())! * app_state.property.eth_rmb_price).formatCurrency(digitNum: 2)
//        }
//
//        let cyb  = source.cyb.toDouble() ?? 0
//
//        if cyb == 0 {
//          cybAmount.text = "--"
//        }else{
//          cybAmount.text = String(cyb * (amount.text?.toDouble())!).formatCurrency(digitNum: 5)
//        }
//
//        let buckets = app_data.data.value.filter { (homebucket) -> Bool in
//          return homebucket.base == AssetConfiguration.CYB && homebucket.quote == balance.asset_type
//        }
//        if let bucket = buckets.first {
//          DispatchQueue.global().async {
//            let matrix = BucketMatrix(bucket)
//
//            DispatchQueue.main.async {
//              self.high_low_label.text = (matrix.incre == .greater ? "+" : "") + matrix.change + "%"
//              self.high_low_icon.image = matrix.incre.icon()
//              self.high_low_label.textColor = matrix.incre.color()
//            }
//          }
//        }
//        else {
//          self.high_low_label.textColor = .coolGrey
//          self.high_low_label.text = "-"
//          self.high_low_icon.image = #imageLiteral(resourceName: "ic_arrow_grey2.pdf")
//        }
      }
    }
  }
  
  fileprivate func setup() {
    bottomView.isHidden = true
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
