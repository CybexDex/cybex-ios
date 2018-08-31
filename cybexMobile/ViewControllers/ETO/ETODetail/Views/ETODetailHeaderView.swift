//
//  ETODetailHeaderView.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Fakery
import SwiftTheme

@IBDesignable
class ETODetailHeaderView: BaseView {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var progressView: LockupProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stateImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    enum Event:String {
        case ETODetailHeaderViewDidClicked
    }

    override func setup() {
        super.setup()
        
        setupUI()
        setupSubViewEvent()
    }
    
    func setupUI() {
        setupStateImgOnGoingCN()
        let faker = Faker.init()
        iconImgView.kf.setImage(with: URL(string: faker.company.logo()))
        timeLabel.text = faker.business.creditCardExpiryDate()?.string()
        progressValue = 0.5
        progressLabel.text = "48%"
        nameLabel.text = faker.name.name()
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
    
    func setupStateImgOnGoingCN() {
        stateImgView.image = R.image.ongoingcn()
    }
    
    func setupStateImgEndCN() {
        stateImgView.image = R.image.endcn()
    }
    
    func setupStateImgWillStartCN() {
        stateImgView.image = R.image.willstartcn()
    }
    
    func setupStateImgOnGoingEN() {
        stateImgView.image = R.image.ongoingen()
    }
    
    func setupStateImgEndEN() {
        stateImgView.image = R.image.enden()
    }
    
    func setupStateImgWillStartEN() {
        stateImgView.image = R.image.willstarten()
    }
    
    @objc override func didClicked() {
        self.next?.sendEventWith(Event.ETODetailHeaderViewDidClicked.rawValue, userinfo: ["data": self.data ?? "", "self": self])
    }
}
