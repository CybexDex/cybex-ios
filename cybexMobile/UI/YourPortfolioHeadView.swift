//
//  YourPortfolioHeadView.swift
//  cybexMobile
//
//  Created by zhusongyu on 2018/7/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class YourPortfolioHeadView: UIView {
  
  @IBOutlet weak var memberLevel: UILabel!
  @IBOutlet weak var totalBalance: UILabel!
  @IBOutlet weak var balanceRMB: UILabel!
  @IBOutlet weak var helpButton: UIButton!
  
  var balanceIntroduceView : BalanceIntroduceView {
    get{
      let biView = BalanceIntroduceView(frame: UIScreen.main.bounds)
      UIApplication.shared.keyWindow?.addSubview(biView)
      return biView
    }
  }
  
  enum event: String {
    case help
  }
  
  var data: Any? {
    didSet {
      
    }
  }
  
  func setup(){
    memberLevel.localized_text = R.string.localizable.account_property.key.localizedContainer()
    if UserManager.shared.balance == 0 {
      totalBalance.text = "0.00000"
    }else{
      totalBalance.text = UserManager.shared.balance.formatCurrency(digitNum: 5)
    }
    
    if let ethAmount = changeToETHAndCYB(AssetConfiguration.CYB).eth.toDouble(){
      if UserManager.shared.balance == 0 {
        balanceRMB.text   = "≈¥0.00"
      }else{
        balanceRMB.text   = "≈¥" + String(UserManager.shared.balance * ethAmount * app_state.property.eth_rmb_price).formatCurrency(digitNum: 2)
      }
    }
    
    helpButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] touch in
      guard let `self` = self else {return}
      let _ = self.balanceIntroduceView
//      guard let `self` = self else { return }
//      self.sendEventWith(event.help.rawValue, userinfo: [ : ])
      }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    
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
