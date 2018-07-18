//
//  EOSWithdrawView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class EOSWithdrawView: UIView {
    
    enum event_name : String {
        case copyAccount
        case copyCode
        case resetCode
    }
    
    
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var memo: UILabel!
    @IBOutlet weak var introduce: UILabel!
    
    @IBOutlet weak var copyAddress: UIButton!
    @IBOutlet weak var resetAddress: UIButton!
    
    
  var data : Any?{
    didSet{
      if let data = data as? AccountAddressRecord{
        let address = data.address
        self.memo.text = address.components(separatedBy: "[").last?.replacingOccurrences(of: "]", with: "")
        self.account.text = address.components(separatedBy: "[").first
      }
    }
  }
    
    @IBAction func copyAccount(_ sender: Any) {
      self.next?.sendEventWith(event_name.copyAccount.rawValue, userinfo: ["account":self.account.text ?? ""])
    }
    
    @IBAction func copyCode(_ sender: Any) {
        self.next?.sendEventWith(event_name.copyCode.rawValue, userinfo: ["memo":self.memo.text ?? ""])
    }
    
    @IBAction func resetCode(_ sender: Any) {
        self.next?.sendEventWith(event_name.resetCode.rawValue, userinfo: [:])
    }
  
  
  func setup(){
    if UIScreen.main.bounds.width == 320 {
      resetAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
      copyAddress.titleLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
    }
  }
  
    
    fileprivate func updateHeight(){
        layoutIfNeeded()
        self.height = dynamicHeight()
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: dynamicHeight())
    }
    
    
    fileprivate func dynamicHeight() -> CGFloat {
        let view = self.subviews.last?.subviews.last
        return (view?.frame.origin.y)! + (view?.frame.size.height)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXIB()
      setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromXIB()
      setup()
    }
    
    
    func loadFromXIB(){
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
