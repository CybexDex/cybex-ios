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
    @IBOutlet weak var sendBtn: UIButton!
    
    
    enum Event:String {
        case chatUpInputViewDidClicked
        case sendMessageEvent
        case sendRealName
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
        
    }
    
    func setupUI() {
        setupBtnState()
    }
    
    func setupBtnState() {
        if !UserManager.shared.logined {
            self.sendBtn.setTitle(R.string.localizable.eto_project_login.key.localized(), for: .normal)
            return
        }
        
        if let text = self.textView.text {
            if text.count == 0 {
                self.sendBtn.setTitleColor(UIColor.steel, for: .normal)
                self.sendBtn.isEnabled = false
            }
            else {
                self.sendBtn.setTitleColor(UIColor.primary, for: .normal)
                self.sendBtn.isEnabled = true
            }
        }
    }
    
    func setupSubViewEvent() {
        NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification,
                                               object: self.textView,queue: nil) { [weak self](notification) in
            guard let self = self else { return }
            let count = self.textView.text.count
            if count < 100 {
                self.numberOfTextLabel.text = "\(self.textView.text.count)/100"
                self.numberOfTextLabel.textColor = UIColor.steel
            }
            else {
                self.numberOfTextLabel.text = "100/100"
                self.numberOfTextLabel.textColor = UIColor.reddish
                self.textView.text = self.textView.text.substring(from: 0, length: 100)
                DispatchQueue.main.async {
                    self.textView.selectedRange = NSMakeRange(100, 0)
                }
            }
            self.setupBtnState()
        }
    }
    
    
    @IBAction func changeRealNameAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.next?.sendEventWith(Event.sendRealName.rawValue, userinfo: ["isRealName": self.realNameBtn.isSelected])
    }
    
    @IBAction func sendMessageAction(_ sender: UIButton) {
        if !UserManager.shared.logined {
            appCoodinator.showLogin()
            return
        }
        self.next?.sendEventWith(Event.sendMessageEvent.rawValue,
                                 userinfo: ["message": self.textView.text ?? ""])
        self.textView.resignFirstResponder()
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.chatUpInputViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}
