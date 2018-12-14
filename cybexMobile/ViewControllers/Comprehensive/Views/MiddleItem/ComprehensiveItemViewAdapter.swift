//
//  ComprehensiveItemViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension ComprehensiveItemView {
    func adapterModelToComprehensiveItemView(_ model: ComprehensiveItem) {
        if self.tapIndex == 0 {
            icon.image = R.image.game_icon()
            titleLabel.text = R.string.localizable.game_center_title.key.localized()
            subTitleLabel.text = R.string.localizable.game_center_subtitle.key.localized()
        }
        else {
            icon.kf.setImage(with: URL(string: model.icon))
            titleLabel.text = model.title
            subTitleLabel.text = model.desc
        }
    }
}
