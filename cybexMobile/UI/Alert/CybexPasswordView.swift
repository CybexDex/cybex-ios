
//
//  CybexPasswordView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/25.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Localize_Swift
import SwiftTheme

class CybexPasswordView: UIView {
  
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var error: UILabel!
  var data : Any? {
    didSet{
      if let data = data as? String{
        if data.count > 0 {
          errorView.isHidden = false
          error.text = data
        }else{
          errorView.isHidden = true
        }
      }
    }
  }
  
  func setup(){
    self.textField.placeholder = R.string.localizable.password_placeholder.key.localized()
    
    if ThemeManager.currentThemeIndex == 0 {
      self.textField.textColor = .white
    }else{
      self.textField.textColor = .darkTwo
    }
    self.textField.setPlaceHolderTextColor(UIColor.steel50)
  }
  
  fileprivate func dynamicHeight() -> CGFloat{
    let lastView = self.subviews.last?.subviews.last
    return (lastView?.frame.origin.y)! + (lastView?.frame.size.height)!
  }
  
  fileprivate func updateHeight(){
    layoutIfNeeded()
    self.frame.size.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    loadFromXIB()
    setup()
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

extension CybexPasswordView : Views{
  var content : Any? {
    get{
      return self.data
    }
    set {
      self.data = newValue
    }
  }
}

