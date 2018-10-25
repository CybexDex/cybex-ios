//
//  ComprehensiveBlockItemsView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ComprehensiveBlockItemsView: CybexBaseView {

    @IBOutlet weak var titleLabel: BaseLabel!

    @IBOutlet weak var contentView: GridContentView!

    var items: [ComprehensiveBlockItemView]!
    enum Event: String {
        case ComprehensiveBlockItemsViewDidClicked
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
        self.next?.sendEventWith(Event.ComprehensiveBlockItemsViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}

extension ComprehensiveBlockItemsView: GridContentViewDataSource {
    func itemsForView(_ view: GridContentView) -> [UIView] {

        let views = Array(0...3).map { (_) -> ComprehensiveBlockItemView in
            let item = ComprehensiveBlockItemView()
            return item
        }
        items = views
        return views
    }

    @objc func edgeInsetsForView(_  view: GridContentView) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    @objc func lineGapForView(_ view: GridContentView) -> CGFloat {
        return 3
    }

    @objc func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 2
    }

    @objc func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat {
        return 86
    }

    @objc func lineSpaceForView(_ view: GridContentView) -> CGFloat {
        return 3
    }

}
