//
//  LockupAssetsView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Kingfisher

class LockupAssetsView: UIView{
  
  var data: Any? {
    didSet {
      guard let data = data as? LockupAssteData else{ return }
    
      self.iconImgV.kf.setImage(with: URL(string: data.icon))
      nameL.text            = data.name.filterJade
      progressL.text        = "\(Int(data.progress.toDouble()! * 100.0))%"
      if let progress = data.progress.toDouble(){
        progressView.progress = progress
      }else{
        progressView.progress = 0
      }
      amountL.text          = data.amount
      RMBCountL.text        = data.RMBCount
      endTimeL.text         = data.endTime
    }
  }
  @IBOutlet weak var iconImgV: UIImageView!
  @IBOutlet weak var nameL: UILabel!
  @IBOutlet weak var progressL: UILabel!
  @IBOutlet weak var progressView: LockupProgressView!
  @IBOutlet weak var amountL: UILabel!
  @IBOutlet weak var RMBCountL: UILabel!
  @IBOutlet weak var endTimeL: UILabel!
  
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
