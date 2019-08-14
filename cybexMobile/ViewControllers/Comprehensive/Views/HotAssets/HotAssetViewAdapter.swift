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
        guard let baseInfo = appData.assetInfo[model.base],
            let quoteInfo = appData.assetInfo[model.quote] else { return }

        assetName.text = quoteInfo.symbol.filterSystemPrefix + "/" + baseInfo.symbol.filterSystemPrefix
        if model.latest == "0" {
            amountLabel.text = "-"
            rmbLabel.text = "-"
            trendLabel.text = "-"
        } else {
            let tradePrecision = TradeConfiguration.shared.getPairPrecisionWithPair(
                Pair(base: model.base, quote: model.quote)
            )
            amountLabel.text = model.latest.formatCurrency(digitNum: tradePrecision.book.lastPrice.int!)
            amountLabel.textColor = model.incre.color()
            self.trendLabel.text = (model.incre == .greater ? "+" : "") +
                model.percentChange.formatCurrency(digitNum: AppConfiguration.amountPrecision) + "%"
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
            self.rmbLabel.text = price == 0 ? "-" : "≈¥" + price.formatCurrency(digitNum: AppConfiguration.rmbPrecision)
        }
    }
}
