//
//  ChatUpInputView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/13.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ChatUpInputView: CybexBaseView {
    
    @IBOutlet weak var realNameBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var numberOfTextLabel: UILabel!
    
    
    enum Event:String {
        case ChatUpInputViewDidClicked
        case sendMessage
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
        
    }
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        self.textView.becomeFirstResponder()
//    }
    
    func setupUI() {
        
    }
    
    func setupSubViewEvent() {
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification,
                                               object: self.textView,queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
                                                
            let count = self.textView.text.count
            if count < 100 {
                self.numberOfTextLabel.text = "\(self.textView.text.count)/100"
                self.numberOfTextLabel.textColor = UIColor.steel
            }
            else {
                self.numberOfTextLabel.text = "100/100"
                self.numberOfTextLabel.textColor = UIColor.reddish
                
                self.textView.text = self.textView.text.substring(from: 0, length: 100)
            }
        }
    }
    
    @IBAction func changeRealNameAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        self.textView.resignFirstResponder()
        self.next?.sendEventWith(Event.sendMessage.rawValue,
                                 userinfo: ["message": self.textView.text,
                                            "isRealName": self.realNameBtn.isSelected])
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ChatUpInputViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}
