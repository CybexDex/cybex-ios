//
//  PostVestingView.swift
//  cybexMobile
//
//  Created by koofrank on 2019/1/24.
//  Copyright © 2019 Cybex. All rights reserved.
//

import Foundation
import TinyConstraints
import GrowingTextView

class PostVestingView: UIView {
    var stackviews: UIStackView!
    var switchButton: UIButton!
    var helpButton: UIButton!
    var dropButton: DropDownBoxView!
    var timeTextFiled: UITextField!
    var pubkeyTextview: GrowingTextView!

    var switchStatus: Bool = false {
        didSet {
            switchButton.isSelected = switchStatus
        }
    }

    enum Event:String {
        case choosePubKeyDidClicked
        case switchStatusDidSwitched
        case showHintContent
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

        self.stackviews.arrangedSubviews[1].isHidden = closed
    }

    func clearPubkey() {
        self.pubkeyTextview.isScrollEnabled = true
        self.pubkeyTextview.text = ""
    }

    func setPubkey(_ text: String) {
        self.pubkeyTextview.text = text
        self.pubkeyTextview.isScrollEnabled = false
    }

    func hiddenPubkey() {
        stackviews.arrangedSubviews[2].isHidden = true
    }

    func showPubkey() {
        stackviews.arrangedSubviews[2].isHidden = false
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

    @objc func showHintContent() {
        self.next?.sendEventWith(Event.showHintContent.rawValue, userinfo: [:])
    }
}
