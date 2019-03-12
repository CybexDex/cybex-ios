//
//  OpenedOrdersCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/14.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class OpenedOrdersCell: BaseTableViewCell {
    
    @IBOutlet weak var orderView: OpenedOrdersView!
    
    var cellType: Int = 1 {
        didSet {
            if cellType != 1 {
                orderView.basePriceView.isHidden = false
                orderView.cancelButton.isHidden       = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setup(_ data: Any?, indexPath: IndexPath) {
        orderView.setupData(data, indexPath: indexPath)
    }
}
