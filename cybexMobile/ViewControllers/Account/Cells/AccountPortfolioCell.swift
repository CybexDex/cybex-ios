//
//  AccountPortfolioCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/16.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit
import SwiftTheme

class AccountPortfolioCell: BaseCollectionViewCell {

  @IBOutlet weak var contentview: UIView!

  @IBOutlet weak var portfolioCellView: AccountPortfolioCellView!
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.masksToBounds       = false
    self.contentview.shadowColor   = ThemeManager.currentThemeIndex == 0 ? .black10 : .steel20
    self.contentview.shadowOffset  = CGSize(width: 0, height: 8.0)
    self.contentview.shadowRadius  = 4
    self.contentview.shadowOpacity = 1.0
  }

  override func setup(_ data: Any?) {
    portfolioCellView.data = data
  }
}
