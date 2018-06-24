//
//  BusinessView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/6/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class BusinessView: UIView {
  @IBOutlet weak var button: Button!
  @IBOutlet weak var errorMessage: UILabel!
  @IBOutlet weak var balance: UILabel!
  
  @IBOutlet weak var fee: UILabel!
  @IBOutlet weak var endMoney: UILabel!
  @IBOutlet weak var baseName: UILabel!
  @IBOutlet weak var value: UILabel!

  @IBOutlet weak var priceTextfield: UITextField!
  @IBOutlet weak var amountTextfield: UITextField!

  @IBOutlet var percents: [UILabel]!
  
  @IBAction func changePrice(_ sender: UIButton) {
    if sender.tag == 1001{
      // -
      
    }else{
      // +
      
    }
  }
  
  var data: Any? {
    didSet {
      
    }
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
