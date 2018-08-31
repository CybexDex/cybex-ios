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
import Fakery

@IBDesignable
class ETOHomeBannerView: BaseView {
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pagerControl: FSPageControl!
    
    enum Event:String {
        case ETOHomeBannerViewDidClicked
    }
        
    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        self.setPagerViewStyle()
    }
    
    func setPagerViewStyle() {
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: FSPagerViewCell.self))

        self.pagerControl.contentHorizontalAlignment = .center
        self.pagerControl.numberOfPages = 5
        self.pagerControl.currentPage = 1
    }
    
    func setupSubViewEvent() {
    
    }
    
 
}

extension ETOHomeBannerView : FSPagerViewDataSource,FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        
        return 5
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: String(describing: FSPagerViewCell.self), at: index) as FSPagerViewCell
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.kf.setImage(with: URL(string: Faker().company.logo()))
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        self.next?.sendEventWith(Event.ETOHomeBannerViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        if self.pagerControl.currentPage != pagerView.currentIndex {
            self.pagerControl.currentPage = pagerView.currentIndex
        }
    }
}


