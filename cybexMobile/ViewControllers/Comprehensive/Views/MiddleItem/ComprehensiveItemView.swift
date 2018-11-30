//
//  ComprehensiveItemView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ComprehensiveItemView: CybexBaseView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    enum Event: String {
        case comprehensiveItemViewDidClicked
    }

    var tapIndex: Int = 0
    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.comprehensiveItemViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self, "index": self.tapIndex])
    }
}
