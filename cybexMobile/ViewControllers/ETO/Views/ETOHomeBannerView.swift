//
//  ETOHomeBannerView.swift
//  cybexMobile
//
//  Created DKM on 2018/8/29.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import FSPagerView
import TinyConstraints

@IBDesignable
class ETOHomeBannerView: BaseView {
    
    var pagerView : FSPagerView!
    
    enum Event:String {
        case ETOHomeBannerViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        self.pagerView = FSPagerView(frame:.zero)
        self.addSubview(self.pagerView)
        self.pagerView.edges(to: self)
        self.layoutIfNeeded()
        self.setPagerViewStyle()
    }
    
    func setPagerViewStyle() {
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: FSPagerViewCell.self))
        self.pagerView.itemSize = CGSize(width: self.width, height: self.height)
        self.pagerView.isInfinite = true
        self.pagerView.automaticSlidingInterval = 3.0
        self.pagerView.dataSource = self
        self.pagerView.delegate = self
    }
    
    func setupSubViewEvent() {
    
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETOHomeBannerViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension ETOHomeBannerView : FSPagerViewDataSource,FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 5
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: String(describing: FSPagerViewCell.self), at: index)

        cell.imageView?.kf.setImage(with: URL(string: "https://www.google.com.hk/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
}
