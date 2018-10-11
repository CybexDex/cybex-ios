//
//  HotAssetsView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class HotAssetsView: CybexBaseView {
    
    @IBOutlet weak var contentView: GridContentView!
    var itemViews: [HotAssetView]!
    
    enum Event:String {
        case HotAssetsViewDidClicked
    }
    
    override var data: Any? {
        didSet {
            if let data = data as? [HomeBucket], data.count != 0 {
                if self.itemViews == nil || self.itemViews.count == 0{
                    self.contentView.reloadData()
                }
                for index in 0..<data.count {
                    self.itemViews[index].adapterModelToHotAssetView(data[index])
                }
//                self.contentView.reloadData()
            }
        }
    }
        
    override func setup() {
        super.setup()
        contentView.datasource = self
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        clearBgColor()
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.HotAssetsViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension HotAssetsView : GridContentViewDataSource{
    func itemsForView(_ view: GridContentView) -> [UIView] {
        if let data = self.data as? [HomeBucket] {
            let views = Array(0...data.count - 1).map({ (index) -> HotAssetView in
                let item = HotAssetView(frame: .zero)
                item.theme1BgColor = .dark
                item.theme2BgColor = .paleGrey
                item.adapterModelToHotAssetView(data[index])
                return item
            })
            itemViews = views
            return views
        }
      
        return []
    }
    
    @objc func lineGapForView(_ view: GridContentView) -> CGFloat {
        return 0
    }
    
    @objc func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 3
    }
    
    @objc func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat {
        return 90
    }
}
