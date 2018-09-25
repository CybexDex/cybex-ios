//
//  RecodeCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class RecodeCellView: UIView {

  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var state: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var address: UILabel!
    @IBOutlet weak var inComeOrSend: UIImageView!
    
  var data : Any? {
    didSet{
      if let data = data as? Record {
        let contentStyle = ThemeManager.currentThemeIndex == 0 ?  "node_dark" : "node_white"
        time.text = data.updateAt.string(withFormat: "MM/dd HH:mm:ss")
        name.text = data.asset.filterJade
        state.text = data.state.desccription()
        
        var assetInfo: AssetInfo?
        for (_, value) in app_data.assetInfo {
            if value.symbol.filterJade == data.asset.filterJade {
                assetInfo = value
                break
            }
        }
        if let asset_info = assetInfo {
            let withdrawAddress = AddressManager.shared.containAddressOfWithDraw(data.address, currency: asset_info.id)
            let attributedString = withdrawAddress.0 == true ? "<\(contentStyle)>\(withdrawAddress.1.first!.name)</\(contentStyle)>\n<address>\(data.address)</address>".set(style: StyleNames.address.rawValue) :  "<address>\(data.address)</address>".set(style: StyleNames.address.rawValue)
            address.attributedText = attributedString
            icon.kf.setImage(with: URL(string: AppConfiguration.SERVER_ICONS_BASE_URLString + asset_info.id.replacingOccurrences(of: ".", with: "_") + "_grey.png"))
            amount.text = getRealAmount(asset_info.id, amount: String(data.amount)).string.formatCurrency(digitNum: asset_info.precision) + " " +  asset_info.symbol.filterJade
        }
        else {
            amount.text = "-"
        }
        inComeOrSend.image = data.fundType == "WITHDRAW" ? R.image.ic_income() : R.image.ic_send()
        updateHeight()
      }
    }
  }
  
  func setup() {
  
  }
  
  fileprivate func updateHeight() {
    layoutIfNeeded()
    self.frame.size.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  override var intrinsicContentSize: CGSize {
    return CGSize.init(width:UIViewNoIntrinsicMetric,height:dynamicHeight())
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
    loadFromXIB()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadFromXIB()
    setup()
  }
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  private func loadFromXIB() {
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
  }
    

}
