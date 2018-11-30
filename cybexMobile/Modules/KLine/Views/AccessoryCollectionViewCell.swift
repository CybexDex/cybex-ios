//
//  AccessoryCollectionViewCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/4/7.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class AccessoryCollectionViewCell: BaseCollectionViewCell {
  @IBOutlet weak var accessoryView: AccessoryCollectionView!

  override func setup(_ data: Any?) {
    self.accessoryView.data = data
  }

  override var isSelected: Bool {
    didSet {
      self.accessoryView.isSelected = isSelected
    }
  }

  override func prepareForReuse() {
    self.accessoryView.isSelected = false
  }
}
