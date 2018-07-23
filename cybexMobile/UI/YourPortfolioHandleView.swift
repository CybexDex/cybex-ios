//
//  YourPortfolioHandleView.swift
//  cybexMobile
//
//  Created by zhusongyu on 2018/7/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
@IBDesignable

class YourPortfolioHandleView: UIView {
  
  @IBOutlet weak var rechargeView: UIView!
  @IBOutlet weak var withdrawDepositView: UIView!
  @IBOutlet weak var transferView: UIView!
  
  enum event: String {
    case recharge
    case withdrawdeposit
    case transfer
  }
  
  func setup(){
    setUpEvent()
    updateHeight()
  }
  
  func setUpEvent() {
    rechargeView.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      self.next?.sendEventWith(event.recharge.rawValue, userinfo: [:])
    }).disposed(by: disposeBag)
    
    withdrawDepositView.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      self.next?.sendEventWith(event.withdrawdeposit.rawValue, userinfo: [:])
    }).disposed(by: disposeBag)
    
    transferView.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] tap in
      guard let `self` = self else { return }
      self.next?.sendEventWith(event.transfer.rawValue, userinfo: [:])
    }).disposed(by: disposeBag)
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
  
  private func updateHeight(){
    layoutIfNeeded()
    self.height = dynamicHeight()
    invalidateIntrinsicContentSize()
  }
  
  override var intrinsicContentSize: CGSize{
    return CGSize(width: UIViewNoIntrinsicMetric, height: dynamicHeight())
  }
  
  fileprivate func dynamicHeight() -> CGFloat{
    let view = self.subviews.last?.subviews.last
    return (view?.frame.origin.y)! + (view?.frame.size.height)!
  }
  
  func loadXIB(){
    let bundle = Bundle(for: type(of: self))
    let nib = UINib.init(nibName: String.init(describing:type(of: self)), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    addSubview(view)
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
  }
}
