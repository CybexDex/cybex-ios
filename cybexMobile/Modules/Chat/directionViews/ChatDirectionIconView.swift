//
//  ChatDirectionIconView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/19.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ChatDirectionIconView: CybexBaseView {
    enum Event:String {
        case chatDirectionIconViewDidClicked
    }
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var notReadCount: Int = 0
    
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
        self.next?.sendEventWith(Event.chatDirectionIconViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
