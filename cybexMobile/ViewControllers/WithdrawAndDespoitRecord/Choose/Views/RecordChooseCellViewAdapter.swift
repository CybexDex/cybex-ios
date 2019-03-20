//
//  RecordChooseCellViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/9/25.
//  Copyright © 2018 Cybex. All rights reserved.
//

import Foundation

extension RecordChooseCellView {
    func adapterModelToRecordChooseCellView(_ model: String) {
        self.nameLabel.text = model.filterSystemPrefix
    }
}
