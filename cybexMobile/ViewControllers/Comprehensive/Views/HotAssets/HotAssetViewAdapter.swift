//
//  HotAssetViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/9/20.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension HotAssetView {
    func adapterModelToHotAssetView(_ model: Ticker) {
        self.data = model
        guard let baseInfo = appData.assetInfo[model.base], let quoteInfo = appData.assetInfo[model.quote] else {return}
        assetName.text = quoteInfo.symbol.filterJade + "/" + baseInfo.symbol.filterJade

        if model.latest == "0" {
            amountLabel.text = "-"
            rmbLabel.text = "-"
            trendLabel.text = "-"
        } else {
            amountLabel.text = model.latest.formatCurrency(digitNum: baseInfo.precision)
            amountLabel.textColor = model.incre.color()
            self.trendLabel.text = (model.incre == .greater ? "+" : "") + model.percentChange.formatCurrency(digitNum: 2) + "%"
            self.trendLabel.textColor = model.incre.color()
            if model.percentChange.decimal() > 1000 {
                self.trendLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
            } else {
                self.trendLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            }
            
            var price: Decimal = 0
            let latest = model.latest.decimal()
            if let baseAsset = AssetConfiguration.CybexAsset(model.base) {
                price = latest * AssetConfiguration.shared.rmbOf(asset: baseAsset)
            }

            self.rmbLabel.text = price == 0 ? "-" : "≈¥" + price.string(digits: 4, roundingMode: .down)
        }
        assetName.textAlignment = .center
        amountLabel.textAlignment = .center
        rmbLabel.textAlignment = .center
        trendLabel.textAlignment = .center
        updateHeight()
    }
}
