//
//  TransferContentView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class TransferContentView: UIView {
  
  enum event : String {
    case transferMemo
  }
  
    @IBOutlet weak var addressView: TransferLineView!
    @IBOutlet weak var timeView: TransferLineView!
    @IBOutlet weak var feeView: TransferLineView!
    @IBOutlet weak var vestingPeriodView: TransferLineView!
    @IBOutlet weak var memoView: TransferLineView!
    
    
  var data : Any? {
    didSet{
        if let data = data as? TransferRecordViewModel {
          addressView.name_locali = data.isSend ? R.string.localizable.transfer_detail_send_address.key.localized() : R.string.localizable.transfer_detail_income_address.key.localized()
//          addressView.content.text = data.isSend ? data.to : data.from
          timeView.content.text = data.time
          
          if data.vesting_period == "" {
            vestingPeriodView.content.text = R.string.localizable.transfer_detail_nodata.key.localized()
          }
          else {
            vestingPeriodView.content.text = data.vesting_period + R.string.localizable.transfer_unit_time.key.localized()
          }
          
          if data.memo == "" {
            memoView.content.text = R.string.localizable.transfer_detail_nodata.key.localized()
          }
          else {
            memoView.content.text = R.string.localizable.transfer_detail_click.key.localized()
            memoView.content.textColor = UIColor.pastelOrange
            memoView.isUserInteractionEnabled = true
            memoView.content.rx.tapGesture().when(.recognized).asObservable().subscribe(onNext: { [weak self](tap) in
              guard let `self` = self else { return }
              self.next?.sendEventWith(event.transferMemo.rawValue, userinfo: ["memoView":""])
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
          }

          if let feeInfo = data.fee,let assetInfo = app_data.assetInfo[feeInfo.asset_id] {
            feeView.content.text = getRealAmount(feeInfo.asset_id, amount: feeInfo.amount).stringValue.formatCurrency(digitNum: assetInfo.precision) + assetInfo.symbol
          }
          updateHeight()
        }
    }
  }
  
  var address_content : String? {
    didSet{
      self.addressView.content.text = self.address_content
    }
  }
  
  var content_text : String? {
    didSet {
      if let text = content_text {
        self.memoView.content_locali = text
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
    return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
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
