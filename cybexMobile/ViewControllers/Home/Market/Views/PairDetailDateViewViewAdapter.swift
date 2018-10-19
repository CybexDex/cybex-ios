//
//  PairDetailDateViewViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/10/17.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

extension PairDetailDateViewView {
    func adapterModelToPairDetailDateViewView(_ model:CBKLineModel) {
        
        self.open.text = R.string.localizable.pair_open.key.localizedFormat(model.open.formatCurrency(digitNum: model.precision))
        self.high.text = R.string.localizable.pair_high.key.localizedFormat(model.high.formatCurrency(digitNum: model.precision))
        self.low.text = R.string.localizable.pair_low.key.localizedFormat(model.low.formatCurrency(digitNum: model.precision))
        self.close.text = R.string.localizable.pair_close.key.localizedFormat(model.close.formatCurrency(digitNum: model.precision))
        self.baseAmount.text = R.string.localizable.pair_vol.key.localizedFormat(model.volume.suffixNumber(digitNum: 2)) + " " +  self.base_name
        
        var lineModels = CBConfiguration.sharedConfiguration.dataSource.drawKLineModels
        let (contain, index) = lineModels.containHashable(model)
        if !contain{
            return
        }
        if index != 0 {
            let beforeModel = lineModels[index - 1]
            if beforeModel.close < model.close {
                model.incre = .greater
                model.changeAmount = "+" + (model.close - beforeModel.close).formatCurrency(digitNum: model.precision)
                model.change = "+" + (((model.close - beforeModel.close) / model.close) * 100).formatCurrency(digitNum: 2) + "%"
            }
            else if beforeModel.close > model.close {
                model.incre = .less
                model.changeAmount = "-" + (beforeModel.close - model.close).formatCurrency(digitNum: model.precision)
                model.change = "-" + (((beforeModel.close - model.close) / model.close) * 100).formatCurrency(digitNum: 2) + "%"
            }
            else {
                model.changeAmount = "0"
                model.change = "0.00"
            }
        }
        
        self.changeAmount.text = R.string.localizable.pair_change_amount.key.localizedFormat(model.changeAmount)
        self.change.text = R.string.localizable.pair_change_persent.key.localizedFormat(model.change)
        self.changeAmount.textColor = model.incre.color()
        self.change.textColor = model.incre.color()
    }
}
