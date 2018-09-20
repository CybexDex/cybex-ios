//
//  ETORecordListViewView.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETORecordListViewView: CybexBaseView {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
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
