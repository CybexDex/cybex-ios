//
//  ETOHomeBannerView.swift
//  cybexMobile
//
//  Created DKM on 2018/8/29.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import FSPagerView

@IBDesignable
class ETOHomeBannerView: CybexBaseView {
    @IBOutlet weak var pagerView: FSPagerView!
    @IBOutlet weak var pagerControl: FSPageControl!

    var view_type: Int = 0
    override var data: Any? {
        didSet {
            if let _ = data as? [String] {
                pagerView.reloadData()
            }
        }
    }

    enum Event: String {
        case ETOHomeBannerViewDidClicked
    }

    override func setup() {
        self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: FSPagerViewCell.self))

        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
        self.setPagerViewStyle()
        self.setPageControlStyle()
    }

    func setPageControlStyle() {
        self.pagerControl.contentHorizontalAlignment = .center
        self.pagerControl.numberOfPages = 5
        self.pagerControl.currentPage = 1
        self.pagerControl.setFillColor(.pastelOrange, for: .selected)
        self.pagerControl.setFillColor(.steel50, for: .normal)
    }

    func setPagerViewStyle() {
        self.pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width, height: self.frame.height)
    }

    func setupSubViewEvent() {

    }
}

extension ETOHomeBannerView: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        if let banners = self.data as? [String] {
            return banners.count
        }
        return 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: String(describing: FSPagerViewCell.self), at: index) as FSPagerViewCell
        if view_type == 0 {
            cell.imageView?.contentMode = .scaleAspectFill
        } else {
            cell.contentView.layer.shadowColor = UIColor.clear.cgColor
            cell.contentView.layer.shadowRadius = 0
            cell.contentView.layer.shadowOpacity = 1.0
            cell.contentView.layer.shadowOffset = .zero
            cell.contentView.cornerRadius = 4
        }

        if let banners = self.data as? [String] {
            let banner = banners[index]
            if banner.contains("https://") || banner.contains("http://") {
                cell.imageView?.kf.setImage(with: URL(string: banner))
            } else {
                cell.imageView?.image = UIImage(named: banner)
            }
        }
        return cell
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        self.next?.sendEventWith(Event.ETOHomeBannerViewDidClicked.rawValue, userinfo: ["data": index, "self": self])
    }

    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        if self.pagerControl.currentPage != pagerView.currentIndex {
            self.pagerControl.currentPage = pagerView.currentIndex
        }
    }
}
