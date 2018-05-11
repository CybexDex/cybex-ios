//
//  HomePairCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class HomePairCell: BaseTableViewCell {
  
  @IBOutlet weak var pairView: HomePairView!
  
  override func setup(_ data: Any?) {
    self.pairView.store = ["index": indexPath!.row]

    self.pairView.data = data
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

  }
  
}
