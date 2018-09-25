//
//  ComprehensiveBlockItemsViewAdapter.swift
//  cybexMobile
//
//  Created DKM on 2018/9/21.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

extension ComprehensiveBlockItemsView {
    func adapterModelToComprehensiveBlockItemsView() {
        for item in self.items {
            item.blockContentLabel.text = "test"
            item.blockTitle.text = "text"
        }
        contentView.updateHeight()
    }
}
