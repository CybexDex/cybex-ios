//
//  WithdrawAddressHomeTableViewCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import Kingfisher

class WithdrawAddressHomeTableViewCell: BaseTableViewCell {

    @IBOutlet weak var foreView: TradeItemView!

    override func setup(_ data: Any?) {
        if let data = data as? WithdrawAddressHomeViewModel {
            foreView.icon.kf.setImage(with: URL(string: data.imageURLString))

            foreView.name.text = data.name
            foreView.amount.text = data.count.value
        }
    }

}
