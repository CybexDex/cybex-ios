//
//  HotAssetView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import RxGesture

@IBDesignable
class HotAssetView: CybexBaseView {
    
    @IBOutlet weak var assetName: BaseLabel!
    @IBOutlet weak var amountLabel: BaseLabel!
    @IBOutlet weak var rmbLabel: BaseLabel!
    @IBOutlet weak var trendLabel: BaseLabel!
    
    enum Event:String {
        case HotAssetViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
//        clearBgColor()
        
    }
    
    func setupSubViewEvent() {
        self.rx.tapGesture().when(.recognized).subscribe(onNext: {[weak self] (tap) in
            guard let `self` = self else { return }
            self.next?.sendEventWith(Event.HotAssetViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
        }).disposed(by: disposeBag)
    }
    
    @objc override func didClicked() {
    }
}
