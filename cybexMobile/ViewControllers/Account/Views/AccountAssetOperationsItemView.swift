//
//  AccountAssetOperationsItemView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Localize_Swift
import SwiftTheme

class AccountAssetOperationsItemView: UIView{
  // 当前页面stackView有三个Lable 前两个是英文。后面是中文
  // lable的tag按照顺序。0  1  2
  enum label_type : NSInteger {
    case first_en = 0
    case last_en  = 1
    case all_cn   = 2
  }
  @IBOutlet weak var stackView: UIStackView!
  var data: Any? {
    didSet {
      
    }
  }
  
  fileprivate func setup() {
    if Localize.currentLanguage() == "zh-Hans" {
      stackView.viewWithTag(0)?.isHidden = true
      stackView.viewWithTag(1)?.isHidden = true
    }else{
      stackView.viewWithTag(2)?.isHidden = true
    }
    self.subviews.last?.shadowColor   = ThemeManager.currentThemeIndex == 0 ? .black10 : .steel20
    self.subviews.last?.shadowOffset  = CGSize(width: 0, height: 8.0)
    self.subviews.last?.shadowRadius  = 4.0
    self.subviews.last?.shadowOpacity = 1.0
    
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
