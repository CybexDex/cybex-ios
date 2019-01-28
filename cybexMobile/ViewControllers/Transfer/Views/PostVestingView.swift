//
//  PostVestingView.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/24.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import TinyConstraints

class PostVestingView: UIView {
    var stackviews: UIStackView!
    var switchButton: UIButton!
    var dropButton: DropDownBoxView!
    var timeTextFiled: UITextField!
    var pubkeyTextFiled: UITextField!

    var switchStatus: Bool = false {
        didSet {
            switchButton.isSelected = switchStatus
        }
    }

    enum Event:String {
        case choosePubKeyDidClicked
        case switchStatusDidSwitched
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        self.dropButton.resetState()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PostVestingView {
    func switchVestingstatus(_ closed: Bool) {
        switchStatus = !closed

        self.stackviews.arrangedSubviews[1...2].forEach({ $0.isHidden = closed})
    }

    func clearPubkey() {
        self.pubkeyTextFiled.text = ""
    }
}

extension PostVestingView {
    @objc func switchVestingDidClicked() {
        switchVestingstatus(switchStatus)
        self.next?.sendEventWith(Event.switchStatusDidSwitched.rawValue, userinfo: [:])
    }

    @objc func choosePubKey() {
        self.next?.sendEventWith(Event.choosePubKeyDidClicked.rawValue, userinfo: [:])
    }
}
