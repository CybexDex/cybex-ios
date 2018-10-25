//
//  WithdrawAddressTableViewCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class WithdrawAddressTableViewCell: BaseTableViewCell {

    @IBOutlet weak var foreView: AddressCellView!

    override func setup(_ data: Any?) {
        if let d = data as? WithdrawAddress {
            foreView.updateUI(d, handler: AddressCellView.adapterWithdrawModelToAddressCellView(foreView))
        }
    }

}
