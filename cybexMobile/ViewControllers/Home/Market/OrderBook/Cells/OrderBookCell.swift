//
//  OrderBookCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class OrderBookCell: BaseTableViewCell {
    
    @IBOutlet weak var ownView: OrderBookCellView!
    
    override func setup(_ data: Any?) {
        self.ownView.data = data
    }
}
