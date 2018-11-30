//
//  BaseCollectionViewCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class BaseCollectionViewCell: UICollectionViewCell {
  public var indexPath: IndexPath?

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func prepareForReuse() {
    super.prepareForReuse()

  }

  func setup(_ data: Any?) {
    fatalError("no implemention setup method")
  }

  func setup(_ data: Any?, indexPath: IndexPath) {
    self.indexPath = indexPath
    setup(data)
  }
}
