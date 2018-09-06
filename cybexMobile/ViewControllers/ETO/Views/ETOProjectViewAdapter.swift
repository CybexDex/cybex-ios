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
        
        if Localize.currentLanguage() == "en" {
            self.icon.kf.setImage(with: URL(string: model.icon_en))
            self.markLabel.text = model.key_words_en
        }
        else {
            self.icon.kf.setImage(with: URL(string: model.icon))
            self.markLabel.text = model.key_words
        }
    }
}
