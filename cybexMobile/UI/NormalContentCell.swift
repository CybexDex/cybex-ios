//
//  NormalContentCell.swift
//  EOS
//
//  Created by DKM on 2018/7/19.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit

class NormalContentCell: BaseTableViewCell {

    @IBOutlet weak var cellView: NormalCellView!

    var selectedIndex: Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func setup(_ data: Any?, indexPath: IndexPath) {
        if let data = data as? AccountViewModel {
            cellView.nameTextOrigin = data.name
            cellView.index = indexPath.row
            cellView.leftIconImg = data.leftImage
            cellView.rightIconName = selectedIndex == indexPath.row ? "icArrowLight24Px" : "icArrowLight24Px"
            cellView.nameLeftConstraint.constant = 54
            cellView.lineView.backgroundColor = UIColor.steel11
            cellView.updateHeight()
        }
    }
}
