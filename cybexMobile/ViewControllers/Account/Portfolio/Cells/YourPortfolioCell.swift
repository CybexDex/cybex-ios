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
    self.contentView.shadowOffset = CGSize(width: 0, height: 8)
    self.contentView.shadowColor   = ThemeManager.currentThemeIndex == 0 ? .black10 : .steel20
    self.contentView.shadowRadius  = 4
    self.contentView.shadowOpacity = 1.0
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
  
}
