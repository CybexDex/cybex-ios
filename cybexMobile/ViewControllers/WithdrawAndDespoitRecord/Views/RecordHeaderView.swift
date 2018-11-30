//
//  RecordHeaderView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/24.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class RecordHeaderView: CybexBaseView {
    enum Event: String {
        case recordHeaderViewDidClicked
    }

    @IBOutlet weak var assetInfoView: RecordChooseView!
    @IBOutlet weak var typeInfoView: RecordChooseView!

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
        self.next?.sendEventWith(Event.recordHeaderViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
