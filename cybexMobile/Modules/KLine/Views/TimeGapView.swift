//
//  TimeGapView.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class TimeGapView: UIView {
  @IBOutlet var buttons: [UIView]!

  enum event: String {
    case timeClicked = "timeClicked"
  }

  enum tags: Int {
    case timeLabel = 1
    case line
  }

  var data: Any? {
    didSet {

    }
  }

  fileprivate func setup() {
    for (idx, button) in buttons.enumerated() {
      button.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] _ in
        guard let `self` = self else { return }

        self.switchButton(idx)
        self.next?.sendEventWith(event.timeClicked.rawValue, userinfo: ["candlestick": candlesticks.all[idx]])

      }).disposed(by: disposeBag)
    }
  }

  func switchButton(_ index: Int) {
    for (idx, button) in buttons.enumerated() {
      let timeLabel = button.viewWithTag(tags.timeLabel.rawValue) as! UILabel
      let line = button.viewWithTag(tags.line.rawValue)
      if idx == index {
        timeLabel.textColor = #colorLiteral(red: 1, green: 0.6386402845, blue: 0.3285836577, alpha: 1)
        line?.isHidden = false
      } else {
        timeLabel.textColor = #colorLiteral(red: 0.5436816812, green: 0.5804407597, blue: 0.6680644155, alpha: 1)
        line?.isHidden = true
      }
    }
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
