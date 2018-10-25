//
//  AnnounceView.swift
//  cybexMobile
//
//  Created DKM on 2018/9/26.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class AnnounceView: CybexBaseView {
    enum Event: String {
        case AnnounceViewDidClicked
    }

    @IBOutlet weak var scrollLableView: AnnounceScrollView!
    @IBOutlet weak var contentView: UIView!
    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {
        clearBgColor()
        contentView.cornerRadius = contentView.height * 0.5
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.AnnounceViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
