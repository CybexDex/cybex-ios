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
        
        model.status.asObservable().subscribe(onNext: { [weak self](status) in
            guard let `self` = self else { return }
            self.stateLabel.text = status
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.current_percent.asObservable().subscribe(onNext: { [weak self](current_progress) in
            guard let `self` = self else { return }
            self.progressLabel.text = current_progress
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.progress.asObservable().subscribe(onNext: { [weak self](progress) in
            guard let `self` = self else { return }
            self.progressView.progress = progress
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        model.project_state.asObservable().subscribe(onNext: { [weak self](projectState) in
            guard let `self` = self, let state = projectState  else { return }
            self.timeState.text = model.timeState
            switch state{
            case .finish:
                self.progressView.beginColor = .slate
                self.progressView.endColor = .cloudyBlue
                self.progressView.progress = model.progress.value
                self.stateLabel.textColor = self.nameLabel.textColor
                self.progressLabel.textColor = self.nameLabel.textColor
            case .ok:
                self.stateLabel.textColor = UIColor.pastelOrange
                self.progressLabel.textColor = UIColor.pastelOrange
            case .pre:
                self.stateLabel.textColor = UIColor.pastelOrange
                self.progressLabel.textColor = UIColor.pastelOrange
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        model.time.asObservable().subscribe(onNext: { [weak self]time in
            guard let `self` = self else {return}
            self.timeLabel.text = time
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        self.nameLabel.text = model.name
        if Localize.currentLanguage() == "en" {
            self.icon.kf.setImage(with: URL(string: model.icon_en))
            self.markLabel.text = model.key_words_en
        }
        else {
            self.icon.kf.setImage(with: URL(string: model.icon))
            self.markLabel.text = model.key_words
        }
        self.updateHeight()
    }
}
