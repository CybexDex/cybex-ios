//
//  ETODetailHeaderViewAdapter.swift
//  cybexMobile
//
//  Created zhusongyu on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Fakery
import Localize_Swift
import SwiftTheme

extension ETODetailHeaderView {
    func adapterModelToETODetailHeaderView(_ model:ETOProjectViewModel) {
        self.iconImgView.kf.setImage(with: URL(string: Localize.currentLanguage() == "en" ? model.icon_en : model.icon))
        self.progressView.progress = model.progress
        self.progressLabel.text = model.current_percent
        self.timeLabel.text = model.timeState + model.time
        self.nameLabel.text = model.name
        if let projectModel = model.projectModel {
            switch projectModel.status! {
            case .finish:
                stateImgView.image = Localize.currentLanguage() == "en" ? R.image.enden() : R.image.endcn()
                self.progressLabel.textColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo
                self.progressView.progress = 1
                self.progressView.beginColor = UIColor.slate
                self.progressView.endColor = UIColor.cloudyBlue
            case .pre:
                stateImgView.image = Localize.currentLanguage() == "en" ? R.image.willstarten() : R.image.willstartcn()
                self.progressLabel.textColor = UIColor.pastelOrange
            case .ok:
                stateImgView.image = Localize.currentLanguage() == "en" ? R.image.ongoingen() : R.image.ongoingcn()
                self.progressLabel.textColor = UIColor.pastelOrange
            }
        }
    }
}
