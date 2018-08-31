//
//  ETORecordListViewView.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETORecordListViewView: BaseView {
    enum Event:String {
        case ETORecordListViewViewDidClicked
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
        self.next?.sendEventWith(Event.ETORecordListViewViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
