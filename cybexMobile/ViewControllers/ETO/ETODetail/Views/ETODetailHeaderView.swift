//
//  ETODetailHeaderView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETODetailHeaderView: BaseView {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var progressView: LockupProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateImgView: UIImageView!
    
    enum Event:String {
        case ETODetailHeaderViewDidClicked
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
        self.next?.sendEventWith(Event.ETODetailHeaderViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
