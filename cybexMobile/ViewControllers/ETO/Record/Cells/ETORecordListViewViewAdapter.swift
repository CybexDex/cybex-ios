//
//  ETORecordListViewViewAdapter.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension ETORecordListViewView {
    func adapterModelToETORecordListViewView(_ model: ETOTradeHistoryModel) {
        nameLabel.text = model.projectName
        actionLabel.text = model.ieoType.showTitle()

        amountLabel.text = "\(model.tokenCount) \(model.token.filterJade)"
        timeLabel.text = model.createdAt.string(withFormat: "yyyy-MM-dd HH:mm:ss")
        statusLabel.text = model.reason.showTitle()
        let reason = (model.reason == .ok || statusLabel.text == R.string.localizable.eto_invalid_partly_sub.key.localized())
        statusLabel.theme_textColor = reason ?
            [UIColor.pastelOrange.hexString(true), UIColor.pastelOrange.hexString(true)] :
            [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
    }
}
