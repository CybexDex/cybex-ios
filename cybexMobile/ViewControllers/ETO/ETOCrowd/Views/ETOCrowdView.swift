//
//  ETOCrowdViewView.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ETOCrowdView: CybexBaseView {

    @IBOutlet weak var gridView: GridContentView!
    @IBOutlet weak var titleTextView: TitleTextfieldView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var actionButton: LGButton!
    @IBOutlet weak var descLabel: BaseLabel!

    @IBOutlet weak var equalLabel: UILabel!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!

    var itemViews: [ETOCrowdGridItemView]!
    static let precision = 6

    enum Event: String {
        case ETOCrowdViewDidClicked
        case ETOCrowdButtonDidClicked
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
        self.gridView.datasource = self

        self.titleTextView.textField.theme_textColor = [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
        self.titleTextView.gapView.isHidden = true
        self.titleTextView.titleLabel.locali = R.string.localizable.eto_quantity.key
        self.titleTextView.textField.placeholder = R.string.localizable.eto_textfiled_placeholder.key.localized()
        self.titleTextView.textField.setPlaceHolderTextColor(UIColor.steel50)
        self.actionButton.locali = R.string.localizable.eto_join.key
        self.actionButton.bgColor = UIColor.steel
//        self.actionButton.isEnabled = false
    }

    func setupSubViewEvent() {
        self.actionButton.addTarget(self, action: #selector(buttonDidClicked), for: .touchUpInside)
    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETOCrowdViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }

    @objc func buttonDidClicked() {
        self.next?.sendEventWith(Event.ETOCrowdButtonDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }

}

extension ETOCrowdView: GridContentViewDataSource {
    func itemsForView(_  view: GridContentView) -> [UIView] {
        let titles = [
            R.string.localizable.eto_personal_cap,
            R.string.localizable.eto_subscription_unit,
            R.string.localizable.eto_remaining,
            R.string.localizable.eto_min_subscription,
            R.string.localizable.eto_subscribed,
            R.string.localizable.eto_total_remaining
        ]

        let views = Array(0...5).map({ (index) -> ETOCrowdGridItemView in
            let item = ETOCrowdGridItemView()
            item.titleLabel.locali = titles[index].key
            item.valueLabel.text = "--"
            item.lineView.isHidden = index == 4
            return item
        })

        itemViews = views
        return views
    }

    @objc func lineGapForView(_ view: GridContentView) -> CGFloat {
        return 0
    }

    @objc func lineMaxItemNum(_ view: GridContentView) -> Int {
        return 2
    }

    @objc func lineHeightForView(_ view: GridContentView, lineNum: Int) -> CGFloat {
        return 69
    }
}
