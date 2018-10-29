//
//  MyHistoryCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/6/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class MyHistoryCell: BaseTableViewCell {
    
    @IBOutlet weak var containerView: MyHistoryCellView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setup(_ data: Any?) {
        containerView.data = data
    }
    
}
