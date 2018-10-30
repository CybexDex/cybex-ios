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


//extension String {
//    static private let SNAKECASE_PATTERN:String = "(\\w{0,1})_"
//    static private let CAMELCASE_PATTERN:String = "[A-Z][a-z,\\d]*"
//    func snake_caseToCamelCase() -> String{
//        let buf:NSString = self.capitalized.replacingOccurrences( of: String.SNAKECASE_PATTERN,
//                                                                  with: "$1",
//                                                                  options: .regularExpression,
//                                                                  range: nil) as NSString
//        return buf.replacingCharacters(in: NSMakeRange(0,1), with: buf.substring(to: 1).lowercased()) as String
//    }
//    func camelCaseTosnake_case() throws -> String {
//        guard let pattern: NSRegularExpression = try? NSRegularExpression(pattern: String.CAMELCASE_PATTERN,
//                                                                          options: []) else {
//                                                                            throw NSError(domain: "NSRegularExpression fatal error occured.", code:-1, userInfo: nil)
//        }
//        
//        let input:NSString = (self as NSString).replacingCharacters(in: NSMakeRange(0,1), with: (self as NSString).substring(to: 1).capitalized) as NSString
//        var array = [String]()
//        let matches = pattern.matches(in: input as String, options:[], range: NSRange(location:0, length: input.length))
//        for match in matches {
//            for index in 0..<match.numberOfRanges {
//                array.append(input.substring(with: match.range(at: index)).lowercased())
//            }
//        }
//        return array.joined(separator: "_")
//    }
//}
