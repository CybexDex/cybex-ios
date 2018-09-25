//
//  ComprehensiveView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ComprehensiveView: CybexBaseView {
    
    @IBOutlet weak var bannerView: ETOHomeBannerView!
    @IBOutlet weak var hotAssetsView: HotAssetsView!
    @IBOutlet weak var moudlesView: ComprehensiveItemsView!
    @IBOutlet weak var blockItemsView: ComprehensiveBlockItemsView!
    
    
    enum Event:String {
        case ComprehensiveViewDidClicked
    }
        
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
        self.next?.sendEventWith(Event.ComprehensiveViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
  
}
