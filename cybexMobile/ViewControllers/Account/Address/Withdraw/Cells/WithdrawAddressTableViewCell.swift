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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
//        foreView.updateUI(1, handler: <#T##((T) -> Void)?##((T) -> Void)?##(T) -> Void#>)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
