//
//  ScanShadeView.swift
//  EOS
//
//  Created by peng zhu on 2018/7/16.
//  Copyright © 2018年 com.nbltrust. All rights reserved.
//

import UIKit

struct ScanSetting {
    static let scanMagin: CGFloat = 70.0
    static let scanWidth: CGFloat = UIScreen.main.bounds.width - scanMagin * 2
    static let scanHeight: CGFloat = scanWidth
    static let scanRect: CGRect = CGRect(x: scanMagin,
                                         y: (UIScreen.main.bounds.height - scanHeight) / 2,
                                         width: scanWidth,
                                         height: scanHeight)
}

class ScanShadeView: UIView {

    lazy var cornerView: ScanCornerView = {
        let cornerView = ScanCornerView.init(frame: ScanSetting.scanRect)
        return cornerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        self.addSubview(cornerView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        UIColor(white: 0.0, alpha: 0.4).setFill()
        UIRectFill(rect)
        let previewRect = rect.intersection(ScanSetting.scanRect)
        UIColor.clear.setFill()
        UIRectFill(previewRect)
    }
}
