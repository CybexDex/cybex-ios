//
//  LockupAssetsCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/15.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class LockupAssetsCell: BaseTableViewCell {
  override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.shadowColor = ThemeManager.currentThemeIndex == 0 ? .black10 : .steel20
    self.contentView.shadowOffset = CGSize(width: 0, height: 8)
    self.contentView.shadowRadius = 4
    self.contentView.shadowOpacity = 1.0
  }
  @IBOutlet weak var lockupCellView: LockupAssetsView!
  
  override func setup(_ data: Any?, indexPath: IndexPath) {
    lockupCellView.data = data
  }
    
}
