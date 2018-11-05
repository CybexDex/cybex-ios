//
//  RechargeHeaderView.swift
//  cybexMobile
//
//  Created DKM on 2018/10/31.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation
import TinyConstraints

@IBDesignable
class RechargeHeaderView: CybexBaseView {
    
    @IBOutlet weak var searchTextField: UITextField!
    var clearSearchBtn: UIButton!
    
    @IBAction func hiddenAssetAction(_ sender: UIButton) {
        self.next?.sendEventWith(Event.rechargeHiddenAsset.rawValue, userinfo: ["data": !sender.isSelected])
        sender.isSelected = !sender.isSelected
    }
    enum Event:String {
        case rechargeHeaderViewDidClicked
        case rechargeHiddenAsset
        case rechargeSortedName
    }
    
    override func setup(){
        super.setup()
        self.showTouchFeedback = false
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        self.searchTextField.placeholder = R.string.localizable.recharge_search_asset.key.localized()
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        let leftImageView = UIImageView(frame: CGRect(x: 6, y: 6, width: 24, height: 24))
        leftImageView.image = R.image.ic_search_24_px()
        self.searchTextField.leftViewMode = .always
        leftView.addSubview(leftImageView)
        self.searchTextField.leftView = leftView
        
        self.searchTextField.rightViewMode = .whileEditing
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        self.clearSearchBtn = UIButton(frame: CGRect(x: 10, y: 10, width: 16, height: 16))
        self.clearSearchBtn.setImage(R.image.ic_cancel_24_px(), for: UIControl.State.normal)
        rightView.addSubview(clearSearchBtn)
        self.searchTextField.rightView = rightView
        self.clearSearchBtn.addTarget(self, action: #selector(btnClick), for: UIControl.Event.touchUpInside)
        
        self.searchTextField.setPlaceHolderTextColor(UIColor.steel50)
    }
    
    func setupSubViewEvent() {
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification
        , object: self.searchTextField, queue: nil) { [weak self](notification) in
            guard let `self` = self, let text = self.searchTextField.text else { return }
            self.next?.sendEventWith(Event.rechargeSortedName.rawValue, userinfo: ["data": text])
        }
    }
    
    @objc func btnClick() {
        self.searchTextField.text = ""
        self.next?.sendEventWith(Event.rechargeSortedName.rawValue, userinfo: ["data": ""])
    }
    
//    @objc override func didClicked() {
//        self.next?.sendEventWith(Event.rechargeHeaderViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
//    }
}
