//
//  ComprehensiveView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import FSPagerView

@IBDesignable
class ComprehensiveView: CybexBaseView {
    
    @IBOutlet weak var bannerView: ETOHomeBannerView!
    @IBOutlet weak var announceView: AnnounceView!
    
    @IBOutlet weak var hotAssetsView: HotAssetsView!
    @IBOutlet weak var moudlesView: ComprehensiveItemsView!

    
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
        self.bannerView.pagerView.transformer = FSPagerViewTransformer(type: .linear)
        self.bannerView.pagerView.itemSize = CGSize(width: 309, height: self.bannerView.height)
        self.bannerView.pagerView.interitemSpacing = 16
        
        self.bannerView.pagerControl.setFillColor(.pastelOrange, for: .selected)
        self.bannerView.pagerControl.setFillColor(.steel50, for: .normal)
        self.bannerView.pagerControl.numberOfPages = 5
    }
    
    func setupSubViewEvent() {
     
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ComprehensiveViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
  
}
