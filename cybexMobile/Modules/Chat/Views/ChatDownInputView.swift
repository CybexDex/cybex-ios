//
//  ChatDownInputView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/13.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ChatDownInputView: CybexBaseView {
    
    @IBOutlet weak var inputTextField: UITextField!
    
    enum Event:String {
        case ChatDownInputViewDidClicked
        case sendMessage
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        self.inputTextField.placeholder = R.string.localizable.chat_input_placeholder.key.localized()
    }
    
    func setupSubViewEvent() {
    
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        guard let text = self.inputTextField.text, text.count != 0  else {
            return
        }
        self.inputTextField.text = ""
        self.next?.sendEventWith(Event.sendMessage.rawValue,
                                 userinfo: ["message": text])
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ChatDownInputViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}
