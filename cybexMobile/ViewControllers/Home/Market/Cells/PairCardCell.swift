//
//  PairCardCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class PairCardCell : BaseCollectionViewCell {
  
    @IBOutlet weak var pairView: PairCardView!
  
    override func setup(_ data: Any?) {
      self.pairView.store = ["index" : indexPath!.item]
      self.pairView.data = data
    }
  
  override var isSelected: Bool {
    didSet {
      self.pairView.isSelected = isSelected
      self.layer.cornerRadius = 4
      self.layer.masksToBounds = true
    }
  }
  
  override func prepareForReuse() {
    self.pairView.isSelected = false
  }
  
}
