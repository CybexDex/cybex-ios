//
//  ChatDirectionLabelView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ChatDirectionLabelView: CybexBaseView {
    enum Event:String {
        case chatDirectionLabelViewDidClicked
    }
        
    @IBOutlet weak var contentLabel: UILabel!
    
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.chatDirectionLabelViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
