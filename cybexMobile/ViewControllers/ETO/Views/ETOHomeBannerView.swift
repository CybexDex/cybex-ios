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
import Localize_Swift
import SwiftTheme
import Device

@IBDesignable
class ETOHomeBannerView: BaseView {
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pagerControl: FSPageControl!
    
    override var data: Any? {
        didSet{
            if let banners = data as? [ETOBannerModel] {
                pagerControl.numberOfPages = banners.count
                pagerControl.currentPage = 0
                if banners.count < 2 {
                    self.pagerView.automaticSlidingInterval = 0
                }
                else {
                    self.pagerView.automaticSlidingInterval = 3
                }
                pagerView.reloadData()
            }
        }
    }
    
    enum Event:String {
        case ETOHomeBannerViewDidClicked
    }
        
    override func setup() {
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: FSPagerViewCell.self))

        super.setup()
        
        setupUI()
        setupSubViewEvent()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: self, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            self.pagerView.reloadData()
        }
    }
    
    func setupUI() {
        self.setPagerViewStyle()
        self.setPageControlStyle()
    }
    
    func setPageControlStyle() {
        self.pagerControl.contentHorizontalAlignment = .center
        self.pagerControl.numberOfPages = 5
        self.pagerControl.currentPage = 1
        self.pagerControl.setFillColor(.paleGrey, for: .selected)
        self.pagerControl.setFillColor(.steel50, for: .normal)
    }
    
    func setPagerViewStyle() {
        self.pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 191)
    }
    
    func setupSubViewEvent() {
    
    }
}

extension ETOHomeBannerView : FSPagerViewDataSource,FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let banners = self.data as? [ETOBannerModel] {
            return banners.count
        }
        return 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: String(describing: FSPagerViewCell.self), at: index) as FSPagerViewCell
        cell.imageView?.contentMode = .scaleAspectFill
        if let banners = self.data as? [ETOBannerModel] {
            let banner = banners[index]
            let bannerUrl = Localize.currentLanguage() == "en" ? banner.adds_banner_mobile__lang_en : banner.adds_banner_mobile
            cell.imageView?.kf.setImage(with: URL(string: bannerUrl))
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if let data = self.data as? [ETOBannerModel], index < data.count {
            self.next?.sendEventWith(Event.ETOHomeBannerViewDidClicked.rawValue, userinfo: ["data": data[index] , "self": self])
        }
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        if self.pagerControl.currentPage != pagerView.currentIndex {
            self.pagerControl.currentPage = pagerView.currentIndex
        }
    }
}


