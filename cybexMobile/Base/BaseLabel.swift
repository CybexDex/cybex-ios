//
//  BaseLabel.swift
//  cybexMobile
//
//  Created by koofrank on 2018/9/3.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation

import Foundation
import SwiftRichString

@IBDesignable
class BaseLabel: UILabel {
    @IBInspectable
    var lineHeight: CGFloat = 0

    override var text: String? {
        didSet {
            decorate()
        }
    }

    override var font: UIFont! {
        didSet {
            decorate()
        }
    }

    override var textColor: UIColor! {
        didSet {
            decorate()
        }
    }

    func decorate() {
        guard let text = text else { return }

        let breakMode = lineBreakMode
        let align = textAlignment

        let style = Style {
            $0.font = self.font
            $0.color = self.textColor
            $0.lineBreakMode = breakMode
            $0.alignment = align
            if self.lineHeight != 0 {
                $0.setupLineHeight(self.lineHeight, fontHeight: self.font.lineHeight)
            }
        }

        let myGroup = StyleGroup(base: style, StylesManager.shared.styles)
        self.attributedText = text.set(style: myGroup)
    }
}
