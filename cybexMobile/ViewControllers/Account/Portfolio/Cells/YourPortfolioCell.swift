//
//  YourPortfolioCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class YourPortfolioCell: BaseTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBOutlet weak var yourPortfolioCellView: YourPorfolioView!
    
    override func setup(_ data: Any?, indexPath: IndexPath) {
        yourPortfolioCellView.data = data
    }    
}
