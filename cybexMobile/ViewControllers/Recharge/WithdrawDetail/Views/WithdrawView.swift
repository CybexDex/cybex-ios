//
//  WithdrawView.swift
//  cybexMobile
//
//  Created by DKM on 2018/7/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import EFQRCode

class WithdrawView: UIView {

    enum event_name : String {
        case saveCode
        case copyAddress
        case resetAddress
    }
    
    
    @IBOutlet weak var codeImg: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var introduce: UILabel!
    
    @IBOutlet weak var copyAddress: UIButton!
    @IBOutlet weak var resetAddress: UIButton!
    
    @IBAction func saveCode(_ sender: Any) {
        self.next?.sendEventWith(event_name.saveCode.rawValue, userinfo: [:])
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        self.next?.sendEventWith(event_name.copyAddress.rawValue, userinfo: [:])
    }
    
    @IBAction func resetAddress(_ sender: Any) {
        self.next?.sendEventWith(event_name.resetAddress.rawValue, userinfo: [:])
    }
  
  
  var data : Any? {
    didSet{
      if let data = data as? AccountAddressRecord {
        self.address.text = data.address
        if let tryImage = EFQRCode.generate(
          content: data.address,
          size: EFIntSize(width: 100, height: 100),
          watermark: UIImage(named: R.image.artboard.name)?.toCGImage()
          ) {
          self.codeImg.image = UIImage(cgImage: tryImage)
        }
      }
    }
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
