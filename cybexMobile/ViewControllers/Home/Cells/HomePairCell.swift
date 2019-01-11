//
//  HomePairCell.swift
//  cybexMobile
//
//  Created by koofrank on 2018/3/13.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

class HomePairCell: BaseTableViewCell {
    enum HomePairCellType: Int {
        case normal = 0
        case topGainers
    }

    @IBOutlet weak var pairView: HomePairView!
    var cellType: HomePairCellType = HomePairCellType.normal

    override func setup(_ data: Any?) {
        self.pairView.store = ["index": indexPath!.row]
        if cellType == HomePairCellType.topGainers {
            self.pairView.replaceIconToLabel()
            self.pairView.ignoreInfoWhenZeroPercent = true
        }

        self.pairView.data = data
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
