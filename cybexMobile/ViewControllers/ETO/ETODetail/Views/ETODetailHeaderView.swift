//
//  ETODetailHeaderView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme

@IBDesignable
class ETODetailHeaderView: CybexBaseView {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var progressView: LockupProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var timeStackView: UIStackView!
    
    enum Event: String {
        case ETODetailHeaderViewDidClicked
    }

    override func setup() {
        super.setup()

        setupUI()
        setupSubViewEvent()
    }

    func setupUI() {

    }

    var progressValue: Double = 0.0 {
        didSet {
            progressView.progress = progressValue
            updateProgressView()
        }
    }

    func updateProgressView() {
        if progressValue == 1 {
            progressView.beginColor = UIColor.slate
            progressView.endColor = UIColor.cloudyBlue
            if ThemeManager.currentThemeIndex == 0 {
                progressLabel.textColor = UIColor.white
            } else {
                progressLabel.textColor = UIColor.darkTwo
            }
        } else {
            progressView.beginColor = UIColor.apricot
            progressView.endColor = UIColor.orangeish
            progressLabel.textColor = UIColor.pastelOrange
        }
    }

    func setupSubViewEvent() {

    }

    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETODetailHeaderViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
