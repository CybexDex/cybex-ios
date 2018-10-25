//
//  YourPortfolioTableHeadView.swift
//  cybexMobile
//
//  Created by zhusongyu on 2018/7/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable

class YourPortfolioTableHeadView: UIView {

  func setup() {
    self.shadowOffset = CGSize(width: 0, height: 8)
    self.shadowColor   = ThemeManager.currentThemeIndex == 0 ? .black10 : .steel20
    self.shadowRadius  = 4
    self.shadowOpacity = 1.0
    updateHeight()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    loadXIB()
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    loadXIB()
    setup()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
  }

  private func updateHeight() {
    layoutIfNeeded()
    self.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: dynamicHeight())
  }

  fileprivate func dynamicHeight() -> CGFloat {
    let view = self.subviews.last?.subviews.last
    return (view?.frame.origin.y)! + (view?.frame.size.height)!
  }

  func loadXIB() {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib.init(nibName: String.init(describing: type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
}
