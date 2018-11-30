//
//  CBKMessageView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class CBKMessageView: CybexBaseView {
    enum Event:String {
        case cBKMessageViewDidClicked
    }
    
    @IBOutlet weak var messageNumberLabel: UILabel!
    
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
        self.next?.sendEventWith(Event.cBKMessageViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}
