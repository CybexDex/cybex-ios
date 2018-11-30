//
//  OpenedOrdersHeaderView.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class OpenedOrdersHeaderView: UIView {

  @IBOutlet weak var totalValueL: UILabel!
  @IBOutlet weak var totalValueTip: UILabel!

    @IBOutlet weak var sectionTitleView: LockupAssetsSectionView!
    var data: Any? {
    didSet {
      if let value = data as? String {
        self.totalValueL.text = value == "0" ? "≈¥0.0000" : "≈¥" + value.formatCurrency(digitNum: 4)
      }
    }
  }

    @IBOutlet weak var sectionView: LockupAssetsSectionView!

  fileprivate func setup() {

  }

  override var intrinsicContentSize: CGSize {
    return CGSize.init(width: UIView.noIntrinsicMetric, height: dynamicHeight())
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
    guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }

    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }

}
