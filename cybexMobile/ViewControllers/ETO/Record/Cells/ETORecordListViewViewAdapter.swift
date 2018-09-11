//
//  ETORecordListViewViewAdapter.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension ETORecordListViewView {
    func adapterModelToETORecordListViewView(_ model:ETOTradeHistoryModel) {
        nameLabel.text = model.project_name
        actionLabel.text = model.ieo_type.showTitle()
        
        amountLabel.text = "\(model.token_count.formatCurrency(digitNum: model.pricision)) \(model.token.filterJade)"
        timeLabel.text = model.created_at.string(withFormat: "yyyy-MM-dd HH:mm:ss")
        statusLabel.text = model.reason.showTitle()
        statusLabel.theme_textColor = model.reason == .ok ? [UIColor.pastelOrange.hexString(true), UIColor.pastelOrange.hexString(true)] : [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
    }
}
