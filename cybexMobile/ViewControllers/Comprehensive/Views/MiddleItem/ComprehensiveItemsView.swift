//
//  ComprehensiveItemsView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ComprehensiveItemsView: CybexBaseView {

    @IBOutlet weak var contentView: GridContentView!
    var itemViews: [ComprehensiveItemView]!

    enum Event: String {
        case comprehensiveItemsViewDidClicked
    }

    override func setup() {
        super.setup()
        contentView.datasource = self
        setupUI()
        setupSubViewEvent()
    }

    override var data: Any? {
        didSet {
            self.contentView.reloadData()
        }
    }

    func setupUI() {
        clearBgColor()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.comprehensiveItemsViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension ComprehensiveItemsView: GridContentViewDataSource {
    func itemsForView(_ view: GridContentView) -> [UIView] {
        if let data = self.data as? [ComprehensiveItem], data.count != 0 {
            let views = Array(0...data.count-1).map { (index) -> ComprehensiveItemView in
                let item = ComprehensiveItemView()
                item.tapIndex = index
                item.adapterModelToComprehensiveItemView(data[index])
                return item
            }
            itemViews = views
            return views
        }
        return []
    }

    @objc func edgeInsetsForView(_  view: GridContentView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
    }

    @objc func lineGapForView(_ view: GridContentView) -> CGFloat {
        return 9
    }

    @objc func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 2
    }

    @objc func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat {
        return 70
    }

    @objc func lineSpaceForView(_ view: GridContentView) -> CGFloat {
        return 9
    }
}
