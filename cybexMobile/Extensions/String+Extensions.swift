//
//  String+Extensions.swift
//  cybexMobile
//
//  Created by koofrank on 2018/9/9.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftTheme
import UIFontComplete
import SwiftRichString

extension String {
    func tagText(_ tag: String) -> String {
        return "<\(tag)>" + self + "</\(tag)>"
    }

    func tagText(_ fontSize: CGFloat = 12,
                 color: UIColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo,
                 lineHeight: CGFloat = 20,
                 font: SystemFonts = SystemFonts.PingFangSC_Regular) -> String {
        let tag = "\(font.rawValue)_\(fontSize)_\(color.hexString(true))_\(lineHeight)"

        if !StylesManager.shared.styles.keys.contains(tag) {
            RichStyle.shared.constructStyle(fontSize, color: color, lineHeight: lineHeight, font: font)
        }

        return tagText(self)
    }
}

extension String {
    
    func snakeCased() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased() ?? self
    }
}
