//
//  RecordChooseCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import UIKit

class RecordChooseCell: BaseTableViewCell {

    @IBOutlet weak var cellView: RecordChooseCellView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setup(_ data: Any?) {
        if let data = data as? String {
            cellView.adapterModelToRecordChooseCellView(data)
        }
    }
}
