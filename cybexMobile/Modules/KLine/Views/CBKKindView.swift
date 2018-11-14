//
//  CBKKindView.swift
//  cybexMobile
//
//  Created DKM on 2018/11/12.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class CBKKindView: CybexBaseView {
    
    @IBOutlet weak var timeView: DropDownBoxView!
    @IBOutlet weak var kindView: DropDownBoxView!
    
    enum Event:String {
        case CBKKindViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
        timeView.nameLabel.text = "1d"
        kindView.nameLabel.text = Indicator.ma.rawValue
        timeView.dropKind = .time
        kindView.dropKind = .kind
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.CBKKindViewDidClicked.rawValue,
                                 userinfo: ["data": self.data ?? "", "self": self])
    }
}
