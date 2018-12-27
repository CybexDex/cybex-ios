//
//  EvaView.swift
//  cybexMobile
//
//  Created KevinLi on 12/26/18.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class EvaView: CybexBaseView {
    @IBOutlet weak var evaIcon: UIImageView!
    enum Event:String {
        case EvaViewDidClicked
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
        self.next?.sendEventWith(Event.EvaViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
