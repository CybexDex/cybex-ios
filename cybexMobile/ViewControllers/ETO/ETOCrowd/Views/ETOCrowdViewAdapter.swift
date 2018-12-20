//
//  ETOCrowdViewViewAdapter.swift
//  cybexMobile
//
//  Created koofrank on 2018/8/30.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import Localize_Swift

extension ETOCrowdView {
    func adapterModelToETOCrowdView(_ model: ETOProjectModel) {
        guard let balances = UserManager.shared.balances.value else { return }

        let balance = balances.filter { (balance) -> Bool in
            if let name = appData.assetInfo[balance.assetType]?.symbol.filterJade {
                return name == model.baseTokenName
            }

            return false
        }.first

        if let balance = balance, let info = appData.assetInfo[balance.assetType] {
            let amount = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).formatCurrency(digitNum: info.precision)
            self.titleTextView.unitLabel.text = R.string.localizable.eto_available.key.localizedFormat(amount, model.baseTokenName)
        } else {
            self.titleTextView.unitLabel.text = R.string.localizable.eto_available.key.localizedFormat("--", model.baseTokenName)
        }

//        let accountName = StyleNames.bold_12_20.tagText("test1")
        self.descLabel.text = Localize.currentLanguage() == "en" ? model.addsBuyDescLangEn : model.addsBuyDesc

        let unit = 1.0 / pow(10, model.baseAccuracy)
        let max = model.baseMaxQuota

        let itemValues = ["\(max) \(model.baseTokenName)", "\(unit) \(model.baseTokenName)", "-- \(model.baseTokenName)", "\(model.baseMinQuota) \(model.baseTokenName)", "--  \(model.baseTokenName)"]

        for (idx, item) in itemViews.enumerated() {
            item.valueLabel.text = itemValues[idx]
        }

    }

    func adapterModelToUserCrowdView(_ model:(projectModel: ETOProjectModel, userModel: ETOUserModel)) {
        let subView = itemViews.last!
        subView.valueLabel.text = "\(model.userModel.currentBaseTokenCount) \(model.projectModel.baseTokenName)"

        let remainView = itemViews[2]
        let remain = model.projectModel.baseMaxQuota - model.userModel.currentBaseTokenCount
        remainView.valueLabel.text = "\(remain) \(model.projectModel.baseTokenName)"
    }

}
