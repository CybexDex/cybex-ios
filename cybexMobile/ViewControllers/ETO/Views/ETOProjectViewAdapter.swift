//
//  ETOProjectViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Fakery
import Localize_Swift
import RxSwift
import RxCocoa

extension ETOProjectView {
    func adapterModelToETOProjectView(_ model:ETOProjectViewModel) {
        self.nameLabel.text = model.name
        self.stateLabel.text = model.status
        self.timeLabel.text = model.time
        self.progressLabel.text = model.current_percent
        self.progressView.progress = model.progress
        self.timeState.text = model.timeState
        if Localize.currentLanguage() == "en" {
            self.icon.kf.setImage(with: URL(string: model.icon_en))
            self.markLabel.text = model.key_words_en
        }
        else {
            self.icon.kf.setImage(with: URL(string: model.icon))
            self.markLabel.text = model.key_words
        }
        if let projectModel = model.model {
            switch projectModel.status! {
            case .finish:
                self.progressView.beginColor = .slate
                self.progressView.endColor = .cloudyBlue
                self.progressView.progress = 1
            case .ok:
                self.stateLabel.textColor = UIColor.pastelOrange
                self.progressLabel.textColor = UIColor.pastelOrange
            case .pre:
                self.stateLabel.textColor = UIColor.pastelOrange
                self.progressLabel.textColor = UIColor.pastelOrange
            }
        }
        self.updateHeight()
    }
}
