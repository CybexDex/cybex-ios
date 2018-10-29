//
//  AddressCellViewAdapter.swift
//  cybexMobile
//
//  Created by koofrank on 2018/8/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension AddressCellView {
    func adapterWithdrawModelToAddressCellView(_ model: WithdrawAddress) {
        nickName.text = model.name
        address.text = model.address
        
        if let memoText = model.memo, !memoText.isEmpty {
            memo.text = memoText
        } else {
            memo.text = ""
        }
    }
}

extension AddressCellView {
    func adapterTransferModelToAddressCellView(_ model: TransferAddress) {
        nickName.text = model.name
        address.text = model.address
    }
}
