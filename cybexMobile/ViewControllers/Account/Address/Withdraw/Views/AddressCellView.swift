//
//  AddressCellView.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class AddressCellView: CybexBaseView {

    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var address: UILabel!

    @IBOutlet weak var memo: UILabel!

    enum Event: String {
        case addressCellViewDidClicked
    }

    override func setup() {
        super.setup()

        setupSubViewEvent()
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.addressCellViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
