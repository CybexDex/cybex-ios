//
//  ETOCrowdGridItemView.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETOCrowdGridItemView: BaseView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    enum Event:String {
        case ETOCrowdGridItemViewDidClicked
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
        self.next?.sendEventWith(Event.ETOCrowdGridItemViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
