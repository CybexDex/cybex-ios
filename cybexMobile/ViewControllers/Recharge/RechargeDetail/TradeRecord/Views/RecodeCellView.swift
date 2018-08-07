//
//  RecodeCellView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class RecodeCellView: UIView {

  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var amount: UILabel!
  @IBOutlet weak var state: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var address: UILabel!
  
  var data : Any? {
    didSet{
      if let data = data as? Record {
        address.text = data.address
        time.text = data.updateAt.string(withFormat: "MM/dd HH:mm:ss")
        name.text = data.asset.filterJade
        state.text = data.state.desccription()
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
    return lastView!.bottom + 8
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
