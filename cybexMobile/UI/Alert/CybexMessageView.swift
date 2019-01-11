//
//  CybexMessageView.swift
//  cybexMobile
//
//  Created DKM on 2018/12/4.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class CybexMessageView: CybexBaseView {
    enum Event:String {
        case cybexMessageViewDidClicked
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override var data: Any? {
        didSet {
            if let data = data as? [String: String] {
                if let messageString = data["message"] {
                    messageLabel.text = messageString
                }
                updateHeight()
            }
        }
    }
    
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    
    
    func setupUI() {
        
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.cybexMessageViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension CybexMessageView: Views {
    var content: Any? {
        get {
            return self.data
        }
        set {
            self.data = newValue
        }
    }
}
