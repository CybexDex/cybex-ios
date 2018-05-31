//
//  AccountAssetOperationView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class AccountAssetOperationView: UIView{
  
  @IBOutlet weak var openedOrdersView: AccountAssetOperationsItemView!
  
  @IBOutlet weak var lockupAssetsView: AccountAssetOperationsItemView!
  
  var data: Any? {
    didSet {
      
    }
  }
  enum event:String{
    case openOpenedOrders
    case openLockupAssets
  }

  fileprivate func setup() {
    openedOrdersView.view_type = 0
    lockupAssetsView.view_type = 1
    
    
    let openedGesture = UITapGestureRecognizer.init(target: self, action: #selector(openOpenedOrders))
    openedOrdersView.addGestureRecognizer(openedGesture)
    
    let lockupAssets = UITapGestureRecognizer.init(target: self, action: #selector(openLockupAssets))
    lockupAssetsView.addGestureRecognizer(lockupAssets)
  }
  
  @objc func openOpenedOrders(){
    openedOrdersView.next?.sendEventWith(event.openOpenedOrders.rawValue, userinfo: [:])
  }
  @objc func openLockupAssets(){
    lockupAssetsView.next?.sendEventWith(event.openLockupAssets.rawValue, userinfo: [:])
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
