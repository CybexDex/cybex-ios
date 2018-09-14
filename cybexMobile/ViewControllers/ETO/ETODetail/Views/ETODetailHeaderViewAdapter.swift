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
import RxCocoa

extension ETODetailHeaderView {
    func adapterModelToETODetailHeaderView(_ model:ETOProjectViewModel) {
        self.nameLabel.text = model.name
        self.iconImgView.kf.setImage(with: URL(string: Localize.currentLanguage() == "en" ? model.icon_en : model.icon))
        model.progress.asObservable().subscribe(onNext: { [weak self](progress) in
            guard let `self` = self else { return }
            self.progressView.progress = progress
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.detail_time.asObservable().subscribe(onNext: { [weak self](time) in
            guard let `self` = self else {return}
            log.debug("timeState :: \(model.timeState)")
            self.timeLabel.text = model.timeState + time
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.current_percent.asObservable().subscribe(onNext: { [weak self](progress) in
            guard let `self` = self else { return }
            self.progressLabel.text = progress
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.project_state.asObservable().subscribe(onNext: { [weak self](state) in
            guard let `self` = self, let project_state = state else { return }
            switch project_state {
            case .finish:
                if ThemeManager.currentThemeIndex == 0 {
                    self.stateImgView.image = Localize.currentLanguage() == "en" ? R.image.end_en_dark() : R.image.end_cn_dark()
                }
                else {
                    self.stateImgView.image = Localize.currentLanguage() == "en" ? R.image.end_en_light() : R.image.end_cn_light()
                }
                self.progressLabel.textColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo
                self.progressView.progress = model.progress.value
                self.progressView.beginColor = UIColor.slate
                self.progressView.endColor = UIColor.cloudyBlue
                self.progressLabel.textColor = self.nameLabel.textColor
            case .pre:
                if ThemeManager.currentThemeIndex == 0 {
                    self.stateImgView.image = Localize.currentLanguage() == "en" ? R.image.comming_en_dark() : R.image.comming_cn_dark()
                }
                else {
                    self.stateImgView.image = Localize.currentLanguage() == "en" ? R.image.comming_en_light() : R.image.comming_cn_light()
                }
                self.progressLabel.textColor = UIColor.pastelOrange
            case .ok:
                self.stateImgView.image = Localize.currentLanguage() == "en" ? R.image.ongoingen() : R.image.ongoingcn()
                self.progressLabel.textColor = UIColor.pastelOrange
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}
