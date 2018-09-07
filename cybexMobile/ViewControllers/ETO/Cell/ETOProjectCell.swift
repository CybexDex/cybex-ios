//
//  ETOProjectCell.swift
//  cybexMobile
//
//  Created by DKM on 2018/8/28.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import UIKit

class ETOProjectCell: BaseTableViewCell {

    @IBOutlet weak var projectView: ETOProjectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setup(_ data: Any?) {
        if let data = data as? ETOProjectViewModel {
            projectView.updateUI(data, handler: ETOProjectView.adapterModelToETOProjectView(projectView))
        }
    }
}
