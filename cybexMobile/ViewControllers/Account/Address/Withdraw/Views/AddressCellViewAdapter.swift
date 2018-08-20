//
//  AddressCellViewAdapter.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension AddressCellView {
    func adapterWithdrawModelToAddressCellView(_ model:WithdrawAddress) {
        nickName.text = model.name
        address.text = model.address
        
        memo.text = model.memo ?? "-"
    }
}

extension AddressCellView {
    func adapterTransferModelToAddressCellView(_ model:TransferAddress) {
        nickName.text = model.name
        address.text = model.address
    }
}



