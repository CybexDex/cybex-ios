//
//  ETORecordListViewViewAdapter.swift
//  cybexMobile
//
//  Created peng zhu on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
/*
 @IBOutlet weak var actionLabel: UILabel!
 @IBOutlet weak var amountLabel: UILabel!
 @IBOutlet weak var timeLabel: UILabel!
 
 var payAssetID: String = ""
 var payAmount: Int = 0
 var receiveAssetID: String = ""
 var receiveAmount: Int = 0
 var occurence: String = ""
 */

extension ETORecordListViewView {
    func adapterModelToETORecordListViewView(_ model: ETOTradeHistoryModel) {
        nameLabel.text = model.exchangeName
//        AssetHelper.getRealAmount(<#T##id: String##String#>, amount: <#T##String#>)
        if let payInfo = appData.assetInfo[model.payAssetID], let receiveInfo = appData.assetInfo[model.receiveAssetID] {
            actionLabel.text = "\(AssetHelper.getRealAmount(model.payAssetID, amount: model.payAmount.string))" + payInfo.symbol.filterSystemPrefix
            amountLabel.text = "\(AssetHelper.getRealAmount(model.receiveAssetID, amount: model.receiveAmount.string))" + receiveInfo.symbol.filterSystemPrefix
        }
        timeLabel.text = model.occurence.string(withFormat: "MM/dd HH:mm")
//        timeLabel.text = model.createdAt.string(withFormat: "yyyy-MM-dd HH:mm:ss")
//        statusLabel.text = model.reason.showTitle()
//        let reason = (model.reason == .ok || statusLabel.text == R.string.localizable.eto_invalid_partly_sub.key.localized())
//        statusLabel.theme_textColor = reason ?
//            [UIColor.pastelOrange.hexString(true), UIColor.pastelOrange.hexString(true)] :
//            [UIColor.white.hexString(true), UIColor.darkTwo.hexString(true)]
    }
}
