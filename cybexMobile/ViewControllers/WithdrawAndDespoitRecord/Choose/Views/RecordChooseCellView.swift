//
//  RecordChooseCellView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class RecordChooseCellView: CybexBaseView {
    enum Event: String {
        case recordChooseCellViewDidClicked
    }
    @IBOutlet weak var nameLabel: UILabel!

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        self.clearBgColor()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.recordChooseCellViewDidClicked.rawValue, userinfo: ["data": self.nameLabel.text ?? "", "self": self])
    }
}
