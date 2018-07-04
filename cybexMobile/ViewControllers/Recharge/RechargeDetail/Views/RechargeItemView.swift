//
//  rechargeView.swift
//  Demo
//
//  Created by DKM on 2018/6/6.
//  Copyright © 2018年 DKM. All rights reserved.
//

import UIKit
import SwiftTheme

enum Recharge_Type:Int{
  case none = 0
  case clean
  case photo
  case all
}


@IBDesignable
class RechargeItemView: UIView {
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var content: ImageTextField!
  @IBOutlet weak var btn: UIButton!
  
  
  @IBInspectable var name : String = "" {
    didSet{
      title.localized_text = name.localizedContainer()
    }
  }
  
  @IBInspectable var SOURCE_TYPE : Int = 0{
    didSet{
      btn_type = Recharge_Type(rawValue: SOURCE_TYPE)
    }
  }
  
  @IBInspectable var textplaceholder : String = "" {
    didSet{
      content.locali = textplaceholder
      content.attributedPlaceholder = NSAttributedString(string:self.content.placeholder!,
                                                         attributes:[NSAttributedStringKey.foregroundColor: UIColor.steel50])
    }
  }
  
  
  var btn_type : Recharge_Type? {
    didSet{
      switch btn_type! {
      case .none:
        btn.isHidden = true
        content.isEnabled = false
      case .clean:
        btn.isHidden = false
        btn.setBackgroundImage(UIImage(named: "icCancel24Px"), for: .normal)
      default:
        break
      }
    }
  }
  
 
  
  func setupUI(){
    self.content.textColor = ThemeManager.currentThemeIndex == 0 ? .white : .darkTwo
  }
  
  fileprivate func updateHeight(){
    layoutIfNeeded()
    self.frame.size.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  override var intrinsicContentSize: CGSize{
    return CGSize.init(width:UIViewNoIntrinsicMetric,height:dynamicHeight())
  }
  
  fileprivate func dynamicHeight() -> CGFloat{
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
    setupUI()
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadFromXIB()
    setupUI()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupUI()
  }
  
  func loadFromXIB(){
    let bundle = Bundle(for: type(of: self))
    let nibName = String(describing: type(of: self))
    let nib = UINib.init(nibName: nibName, bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.layer.cornerRadius = 4.0
    view.clipsToBounds = true
    addSubview(view)
    
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
  }
}
