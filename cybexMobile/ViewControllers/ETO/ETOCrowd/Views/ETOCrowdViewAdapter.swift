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
        guard let balances = UserManager.shared.fullAccount.value?.balances else { return }

        let balance = balances.filter { (balance) -> Bool in
            if let name = appData.assetInfo[balance.assetType]?.symbol.filterSystemPrefix {
                return name == model.baseTokenName
            }

            return false
        }.first
        
        self.titleTextView.unitLabel.text = model.userBuyToken.filterSystemPrefix
        if let balance = balance, let info = appData.assetInfo[balance.assetType] {
            let amount = AssetHelper.getRealAmount(balance.assetType, amount: balance.balance).formatCurrency(digitNum: info.precision)
            self.titleTextView.introduceLabel.text = R.string.localizable.eto_available.key.localizedFormat(amount, model.baseTokenName)
        } else {
            self.titleTextView.introduceLabel.text = R.string.localizable.eto_available.key.localizedFormat("--", model.baseTokenName)
        }
        
        self.descLabel.text = Localize.currentLanguage() == "en" ? model.addsBuyDescLangEn : model.addsBuyDesc
        let unit = 1.0 / pow(10, model.baseAccuracy)
        let max = model.baseMaxQuota.decimal
        var itemValues = [String]()
        if (model.userBuyToken.filterSystemPrefix == model.baseTokenName || model.userBuyToken == "") {
            itemValues = ["\(max) \(model.baseTokenName)", "\(unit) \(model.baseTokenName)", "-- \(model.baseTokenName)", "\(model.baseMinQuota) \(model.baseTokenName)", "--  \(model.baseTokenName)"]
            self.equalLabel.text = "0\(model.tokenName)"
        }
        else {
            let name = model.userBuyToken.filterSystemPrefix
            let quoteAccuracy = model.quoteAccuracy
            let rate = model.quoteTokenCount.decimal() / model.baseTokenCount.decimal()
            itemValues = ["\((max * rate).string()) \(name)", "\(quoteAccuracy) \(name)", "-- \(name)", "\((model.baseMinQuota.decimal * rate).string()) \(name)", "--  \(name)"]
            self.equalLabel.text = "0\(model.baseTokenName)"
        }

        for (idx, item) in itemViews.enumerated() {
            item.valueLabel.text = itemValues[idx]
        }

    }

    func adapterModelToUserCrowdView(_ model:(projectModel: ETOProjectModel, userModel: ETOUserModel)) {
        let subView = itemViews.last!

        let remainView = itemViews[2]
        let remain = model.projectModel.baseMaxQuota - model.userModel.currentBaseTokenCount
        
        if (model.projectModel.userBuyToken.filterSystemPrefix == model.projectModel.baseTokenName || model.projectModel.userBuyToken == "") {
            subView.valueLabel.text = "\(model.userModel.currentBaseTokenCount) \(model.projectModel.baseTokenName)"
            remainView.valueLabel.text = "\(remain) \(model.projectModel.baseTokenName)"
        }else {
            let rate = model.projectModel.quoteTokenCount.decimal() / model.projectModel.baseTokenCount.decimal()
            let name = model.projectModel.userBuyToken.filterSystemPrefix
            subView.valueLabel.text = "\((model.userModel.currentBaseTokenCount.decimal * rate).string()) \(name)"
            remainView.valueLabel.text = "\((remain.decimal * rate).string()) \(name)"
        }
       
    }

}
