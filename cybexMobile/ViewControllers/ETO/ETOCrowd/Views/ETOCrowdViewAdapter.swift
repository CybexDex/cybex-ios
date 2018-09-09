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
    func adapterModelToETOCrowdView(_ model:ETOProjectModel) {
        guard let balances = UserManager.shared.balances.value else { return }
        
        let balance = balances.filter { (balance) -> Bool in
            if let name = app_data.assetInfo[balance.asset_type]?.symbol.filterJade {
                return name == model.base_token_name
            }
            
            return false
        }.first
        
        if let balance = balance, let info = app_data.assetInfo[balance.asset_type] {
            let amount = getRealAmount(balance.asset_type, amount: balance.balance).string(digits: info.precision, roundingMode: .down)
            self.titleTextView.unitLabel.text = R.string.localizable.eto_available.key.localizedFormat(amount, model.base_token_name)
        }
        else {
            self.titleTextView.unitLabel.text = R.string.localizable.eto_available.key.localizedFormat("--", model.base_token_name)
        }
        
//        let accountName = StyleNames.bold_12_20.tagText("test1")
        self.descLabel.text = Localize.currentLanguage() == "en" ? model.adds_buy_desc__lang_en : model.adds_buy_desc
        
        let unit = 1.0 / pow(10, model.base_accuracy)
        let max = model.base_max_quota
        
        let itemValues = ["\(max) \(model.base_token_name)", "\(unit) \(model.base_token_name)", "-- \(model.base_token_name)", "\(model.base_min_quota) \(model.base_token_name)", "--  \(model.base_token_name)"]
        
        for (idx, item) in itemViews.enumerated() {
            item.valueLabel.text = itemValues[idx]
        }
        
    }
    
    func adapterModelToUserCrowdView(_ model:(projectModel:ETOProjectModel, userModel:ETOUserModel)) {
        let subView = itemViews.last!
        subView.valueLabel.text = "\(model.userModel.current_base_token_count) \(model.projectModel.base_token_name)"
        
        let remainView = itemViews[2]
        let remain = model.projectModel.base_max_quota - model.userModel.current_base_token_count
        remainView.valueLabel.text = "\(remain) \(model.projectModel.base_token_name)"
    }
    
}
