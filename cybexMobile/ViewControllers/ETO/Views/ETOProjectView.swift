//
//  ETOProjectView.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETOProjectView: BaseView {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var progressView: LockupProgressView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var timeImgView: UIImageView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    enum Event:String {
        case ETOProjectViewDidClicked
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
        self.next?.sendEventWith(Event.ETOProjectViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
