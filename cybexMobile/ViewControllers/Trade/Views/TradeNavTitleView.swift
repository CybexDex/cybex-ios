//
//  TradeNavTitleView.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/12.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

protocol TradeNavTitleViewDelegate {
  func sendEventActionWith() -> Bool
}

class TradeNavTitleView: UIView {

  @IBOutlet weak var title: UILabel!

  @IBOutlet weak var icon: UIImageView!

  var isSetUp: Bool?

  enum Event_Action: String {
    case changeTitle
  }

  var data: String? {
    didSet {
      title.text = data
    }
  }
  var delegate: TradeNavTitleViewDelegate?

  fileprivate func setup() {
    self.isSetUp = false
    self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
      guard let `self` = self else { return }
      if let dele = self.delegate, dele.sendEventActionWith() {
        self.icon.transform = self.isSetUp == false ? CGAffineTransform(rotationAngle: CGFloat(0.5 * Double.pi)) : CGAffineTransform(rotationAngle: 0)
        self.isSetUp = !self.isSetUp!
      }
    }).disposed(by: disposeBag)
  }

  override var intrinsicContentSize: CGSize {
    return self.size
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
