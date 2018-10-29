//
//  TradeHistoryCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/8.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class TradeHistoryCell: BaseTableViewCell {
    
    @IBOutlet weak var ownView: TradeHistoryCellView!
    
    override func setup(_ data: Any?) {
        self.ownView.data = data
    }
}
