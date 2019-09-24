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
    
    @IBOutlet weak var inputTextField: ImageTextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    
    enum Event:String {
        case chatDownInputViewDidClicked
        case sendMessageEvent
        case callKeyboard
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        setupBtnState()
        
        self.inputTextField.placeholder = R.string.localizable.chat_input_placeholder.key.localized()
        self.inputTextField.setPlaceHolderTextColor(UIColor.steel50)
        self.inputTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.inputTextField.leftViewMode = .always
        self.inputTextField.delegate = self
    }
    
    func setupBtnState() {
        if !UserManager.shared.logined {
            self.sendBtn.setTitle(R.string.localizable.eto_project_login.key.localized(), for: .normal)
            return
        }
        
        if let text = self.inputTextField.text {
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
    
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if !UserManager.shared.logined {
            appCoodinator.showLogin()
            return
        }
        
        guard let text = self.inputTextField.text, text.count != 0  else {
            return
        }
        self.next?.sendEventWith(Event.sendMessageEvent.rawValue,
                                 userinfo: ["message": text])
    }
    
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.chatDownInputViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension ChatDownInputView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.sendEventWith(Event.callKeyboard.rawValue, userinfo: [:])
        return false
    }
}
