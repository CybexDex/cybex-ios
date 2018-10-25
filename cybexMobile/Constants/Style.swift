//
//  Style.swift
//  cybexMobile
//
//  Created by DKM on 2018/5/22.
//  Copyright © 2018年 Cybex. All rights reserved.
//

import Foundation
import SwiftRichString
import Localize_Swift
import SwiftTheme

enum StyleNames: String {
    case introduce_normal
    case introduce
    case password
    case withdraw_introduce
    case alertContent
    case address
    case bold_12_20

    func tagText(_ nestText: String) -> String {
        return "<\(self.rawValue)>" + nestText + "</\(self.rawValue)>"
    }
}

enum LineViewStyleNames: String {
    case normal_name
    case normal_content
    case transfer_confirm
}

extension Style {
    func setupLineHeight(_ lineHeight: CGFloat, fontHeight: CGFloat) {
        self.maximumLineHeight = lineHeight
        self.minimumLineHeight = lineHeight
        self.baselineOffset = labelBaselineOffset(lineHeight, fontHeight: lineHeight)
    }
}

class RichStyle {
    static var shared = RichStyle()

    func start() {

    }

    private init() {
        changeStyleFromTheme()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: {_ in
            self.start()
            self.changeStyleFromTheme()
        })

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: LCLLanguageChangeNotification), object: nil, queue: nil, using: {_ in
            self.start()
            self.changeStyleFromTheme()
        })
    }

    //PingFangSC-Regular_12_#F7F8FAFF_20
    func constructStyle(_ fontSize: CGFloat = 12, color: UIColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo, lineHeight: CGFloat = 20, font: SystemFonts = SystemFonts.PingFangSC_Regular) {
        let style = Style {
            let realfont = font.font(size: fontSize)
            $0.font = realfont
            $0.color = color

            $0.setupLineHeight(lineHeight, fontHeight: realfont.lineHeight)
        }

        Styles.register("\(font.rawValue)_\(fontSize)_\(color.hexString(true))_\(lineHeight)", style: style)
    }

    func tagText(_ nestText: String, fontSize: CGFloat = 12, color: UIColor = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo, lineHeight: CGFloat = 20, font: SystemFonts = SystemFonts.PingFangSC_Regular) -> String {
        let tag = "\(font.rawValue)_\(fontSize)_\(color.hexString(true))_\(lineHeight)"

        if !StylesManager.shared.styles.keys.contains(tag) {
            constructStyle(fontSize, color: color, lineHeight: lineHeight, font: font)
        }
        return "<\(tag)>" + nestText + "</\(tag)>"
    }

    func changeStyleFromTheme() {
        let style = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
            $0.lineSpacing = 8.0
        }
        Styles.register(StyleNames.introduce_normal.rawValue, style: style)

        let introduce_style = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
            $0.lineSpacing = 4.0
        }
        Styles.register(StyleNames.introduce.rawValue, style: introduce_style)

        let with_style = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
            $0.lineSpacing = 4.0
        }
        Styles.register(StyleNames.withdraw_introduce.rawValue, style: with_style)

        let bold_12_20 = Style {
            let font = SystemFonts.PingFangHK_Regular.font(size: 12)
            $0.font = font
            $0.color = ThemeManager.currentThemeIndex == 0 ? UIColor.white : UIColor.darkTwo

            $0.setupLineHeight(20, fontHeight: font.lineHeight)
        }

        Styles.register(StyleNames.bold_12_20.rawValue, style: bold_12_20)

        passwordStyle()
        alertDetailStyle()
        initLineViewStyle()
        addressStyle()
    }

    func addressStyle() {
        let base = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12.0)
        }

        let node_dark = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.lineSpacing = 4
            $0.color = UIColor.white
        }

        let node_white = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.lineSpacing = 4
            $0.color = UIColor.darkTwo
        }

        let address = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 12)
            $0.lineSpacing = 4
            $0.color = UIColor.steel
        }

        let myGroup = StyleGroup(base: base, ["node_dark": node_dark, "node_white": node_white, "address": address])
        StylesManager.shared.register(StyleNames.address.rawValue, style: myGroup)
    }

    func passwordStyle() {
        let normal = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14)
            $0.lineSpacing = 4
            $0.color = UIColor.steel
        }

        let password = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14)
            $0.color = UIColor.maincolor
        }

        let myGroup = StyleGroup(base: normal, ["password": password])
        Styles.register(StyleNames.password.rawValue, style: myGroup)
    }

    func alertDetailStyle() {
        let base = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
        }

        let name = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
            $0.color = UIColor.steel
        }

        let content_buy = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.turtleGreen
        }

        let content_sell = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.reddish
        }

        let content_dark = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.white
        }

        let content_light = Style {
            $0.font = SystemFonts.PingFangSC_Medium.font(size: 14.0)
            $0.color = UIColor.darkTwo
        }

        let myGroup = StyleGroup(base: base, ["name": name, "content_dark": content_dark, "content_light": content_light, "content_sell": content_sell, "content_buy": content_buy])
        StylesManager.shared.register(StyleNames.alertContent.rawValue, style: myGroup)
    }

    func initLineViewStyle() {
        let name_style = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 16.0)
        }
        Styles.register(LineViewStyleNames.normal_name.rawValue, style: name_style)

        let content_style = Style {
            $0.font = SystemFonts.PingFangSC_Regular.font(size: 14.0)
        }
        Styles.register(LineViewStyleNames.normal_content.rawValue, style: content_style)

        let confirm_style = Style {
            $0.font = SystemFonts.PingFangSC_Semibold.font(size: 16.0)
        }
        Styles.register(LineViewStyleNames.transfer_confirm.rawValue, style: confirm_style)

    }
}
