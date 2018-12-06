//
//  PairDetailDateViewViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/10/17.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

extension PairDetailDateViewView {
    func adapterModelToPairDetailDateViewView(_ model: CBKLineModel) {

        self.open.text = R.string.localizable.pair_open.key.localizedFormat(model.open.string(digits: model.precision, roundingMode: .down))
        self.high.text = R.string.localizable.pair_high.key.localizedFormat(model.high.string(digits: model.precision, roundingMode: .down))
        self.low.text = R.string.localizable.pair_low.key.localizedFormat(model.low.string(digits: model.precision, roundingMode: .down))
        self.close.text = R.string.localizable.pair_close.key.localizedFormat(model.close.string(digits: model.precision, roundingMode: .down))
        self.baseAmount.text = R.string.localizable.pair_vol.key.localizedFormat(model.volume.decimal.suffixNumber(digitNum: 2)) + " " +  self.baseName

        var lineModels = CBConfiguration.sharedConfiguration.dataSource.drawKLineModels
        let (contain, index) = lineModels.containHashable(model)
        if !contain {
            return
        }
        if index != 0 {
            let beforeModel = lineModels[index - 1]
            if beforeModel.close < model.close {
                model.incre = .greater
                model.changeAmount = "+" + (model.close - beforeModel.close).string(digits: model.precision, roundingMode: .down)
                model.change = "+" + (((model.close - beforeModel.close) / beforeModel.close) * 100).string(digits: 2, roundingMode: .down) + "%"

            } else if beforeModel.close > model.close {
                model.incre = .less
                model.changeAmount = "-" + (beforeModel.close - model.close).string(digits: model.precision, roundingMode: .down)
                model.change = "-" + (((beforeModel.close - model.close) / beforeModel.close) * 100).string(digits: 2, roundingMode: .down) + "%"
            } else {
                model.changeAmount = "0".formatCurrency(digitNum: model.precision)
                model.change = "0.00" + "%"

            }
        }

        self.changeAmount.text = R.string.localizable.pair_change_amount.key.localizedFormat(model.changeAmount)
        self.change.text = R.string.localizable.pair_change_persent.key.localizedFormat(model.change)
        self.changeAmount.textColor = model.incre.color()
        self.change.textColor = model.incre.color()
    }
}
