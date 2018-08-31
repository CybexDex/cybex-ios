//
//  ContainerView.swift
//  cybexMobile
//
//  Created DKM on 2018/8/31.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

@IBDesignable
class ContainerView: CornerAndShadowView {
        
    override func setup() {
        super.setup()
        
        setupUI()
    }
    func setupUI() {
        self.newCornerRadius = 4
        self.newSpread = -4
        self.newShadowOpcity = 1.0
        self.newShadowOffset = CGSize(width: 0, height: 8)
        self.newTheme1ShadowColor = UIColor.black10
        self.newTheme2ShadowColor = UIColor.steel20
    }
}
